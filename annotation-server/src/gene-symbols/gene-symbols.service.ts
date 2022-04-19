import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { Repository } from 'typeorm';

import { CreateGeneSymbolDto } from './dtos/create-gene-symbol.dto';
import { LookupKeyDto } from './dtos/lookupkey.dto';
import { GeneSymbol } from './entities/gene-symbol.entity';
import { Phenotype } from './entities/phenotype.entity';

@Injectable()
export class GeneSymbolsService {
    constructor(
        private httpService: HttpService,
        @InjectRepository(GeneSymbol)
        private geneSymbolRepository: Repository<GeneSymbol>,
        @InjectRepository(Phenotype)
        private phenotypeRepository: Repository<Phenotype>,
    ) {
        this.hashedPhenotypes = new Map<string, Phenotype>();
    }

    private hashedPhenotypes: Map<string, Phenotype>;

    async fetchLookupKeys(): Promise<void> {
        this.clearAllData();

        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/diplotype',
            { params: { select: 'lookupkey' } },
        );

        const lookupKeyDtos: LookupKeyDto[] = (await lastValueFrom(response))
            .data;

        await this.geneSymbolRepository.save(
            await this.getGeneSymbolDtos(lookupKeyDtos),
        );

        this.hashedPhenotypes.clear();
    }

    private async getGeneSymbolDtos(lookupKeyDtos: LookupKeyDto[]) {
        const genePhenotypes = new Map<string, Set<Phenotype>>();
        for (const lookupKeyDto of lookupKeyDtos) {
            const geneString = Object.keys(lookupKeyDto.lookupkey)[0];
            const phenotypeString = Object.values(lookupKeyDto.lookupkey)[0];

            const phenotype = await this.findOrCreatePhenotype(phenotypeString);

            if (genePhenotypes.has(geneString)) {
                genePhenotypes.get(geneString).add(phenotype);
            } else {
                genePhenotypes.set(geneString, new Set([phenotype]));
            }
        }

        const geneSymbolDtos: CreateGeneSymbolDto[] = [];
        for (const [gene, phenotypes] of genePhenotypes) {
            geneSymbolDtos.push({
                name: gene,
                phenotypes: Array.from(phenotypes),
            });
        }
        return geneSymbolDtos;
    }

    private async findOrCreatePhenotype(name: string): Promise<Phenotype> {
        let phenotype: Phenotype;
        if (!this.hashedPhenotypes.has(name)) {
            phenotype = new Phenotype();
            phenotype.name = name;
            phenotype = await this.phenotypeRepository.save(phenotype);
            this.hashedPhenotypes.set(name, phenotype);
        } else {
            phenotype = this.hashedPhenotypes.get(name);
        }
        return phenotype;
    }

    async clearAllData(): Promise<void> {
        await this.geneSymbolRepository.delete({});
        await this.phenotypeRepository.delete({});
        this.hashedPhenotypes.clear();
    }
}
