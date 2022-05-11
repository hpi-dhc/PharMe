import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { FindOneOptions, Repository } from 'typeorm';

import { CreateGeneSymbolDto } from './dtos/create-gene-symbol.dto';
import { DiplotypeDto } from './dtos/diplotype.dto';
import { GenePhenotype } from './entities/gene-phenotype.entity';
import { GeneSymbol } from './entities/gene-symbol.entity';
import { Phenotype } from './entities/phenotype.entity';

@Injectable()
export class GenePhenotypesService {
    constructor(
        private httpService: HttpService,
        @InjectRepository(GeneSymbol)
        private geneSymbolRepository: Repository<GeneSymbol>,
        @InjectRepository(Phenotype)
        private phenotypeRepository: Repository<Phenotype>,
        @InjectRepository(GenePhenotype)
        private genePhenotypeRepository: Repository<GenePhenotype>,
    ) {
        this.hashedPhenotypes = new Map<string, Phenotype>();
    }

    private hashedPhenotypes: Map<string, Phenotype>;

    async fetchGenePhenotypes(): Promise<void> {
        await this.clearAllData();

        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/diplotype',
            { params: { select: 'generesult,genesymbol' } },
        );

        const diplotypeDtos: DiplotypeDto[] = (await lastValueFrom(response))
            .data;

        await this.geneSymbolRepository.save(
            await this.getGeneSymbolDtos(diplotypeDtos),
        );

        this.hashedPhenotypes.clear();
    }

    private async getGeneSymbolDtos(diplotypeDtos: DiplotypeDto[]) {
        const genePhenotypes = new Map<string, Set<Phenotype>>();
        for (const diplotypeDto of diplotypeDtos) {
            const phenotype = await this.findOrCreatePhenotype(
                diplotypeDto.generesult,
            );

            if (genePhenotypes.has(diplotypeDto.genesymbol)) {
                genePhenotypes.get(diplotypeDto.genesymbol).add(phenotype);
            } else {
                genePhenotypes.set(
                    diplotypeDto.genesymbol,
                    new Set([phenotype]),
                );
            }
        }

        const geneSymbolDtos: CreateGeneSymbolDto[] = [];
        for (const [gene, phenotypes] of genePhenotypes) {
            geneSymbolDtos.push({
                name: gene,
                genePhenotypes: Array.from(phenotypes).map((phenotype) => {
                    const genePhenotype = new GenePhenotype();
                    genePhenotype.phenotype = phenotype;
                    return genePhenotype;
                }),
            });
        }
        return geneSymbolDtos;
    }

    private async findOrCreatePhenotype(
        generesult: string,
    ): Promise<Phenotype> {
        if (this.hashedPhenotypes.has(generesult)) {
            return this.hashedPhenotypes.get(generesult);
        }

        const phenotype = new Phenotype();
        phenotype.name = generesult;

        const storedPhenotype = await this.phenotypeRepository.save(phenotype);
        this.hashedPhenotypes.set(generesult, storedPhenotype);

        return storedPhenotype;
    }

    private async clearAllData(): Promise<void> {
        await this.geneSymbolRepository.delete({});
        await this.phenotypeRepository.delete({});
        this.hashedPhenotypes.clear();
    }

    getOneGeneSymbol(options: FindOneOptions<GeneSymbol>): Promise<GeneSymbol> {
        return this.geneSymbolRepository.findOne(options);
    }

    getOne(options: FindOneOptions<GenePhenotype>): Promise<GenePhenotype> {
        return this.genePhenotypeRepository.findOneOrFail(options);
    }
}
