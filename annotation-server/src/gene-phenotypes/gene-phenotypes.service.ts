import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
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
    private readonly logger = new Logger(GenePhenotypesService.name);

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

        this.logger.log('Fetching gene-phenotype combinations from CPIC.');
        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/diplotype',
            { params: { select: 'lookupkey, generesult' } },
        );

        const diplotypeDtos: DiplotypeDto[] = (await lastValueFrom(response))
            .data;

        await this.geneSymbolRepository.save(
            await this.getGeneSymbolDtos(diplotypeDtos),
        );

        this.hashedPhenotypes.clear();
        this.logger.log(
            'Successfully saved gene-phenotype combinations to database.',
        );
    }

    private async getGeneSymbolDtos(diplotypeDtos: DiplotypeDto[]) {
        const genePhenotypes = new Map<string, Set<Phenotype>>();
        for (const diplotypeDto of diplotypeDtos) {
            const geneString = Object.keys(diplotypeDto.lookupkey)[0];
            const lookupkey = Object.values(diplotypeDto.lookupkey)[0];

            const phenotype = await this.findOrCreatePhenotype(
                lookupkey,
                diplotypeDto.generesult,
            );

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
        lookupkey: string,
        generesult: string,
    ): Promise<Phenotype> {
        if (this.hashedPhenotypes.has(lookupkey)) {
            return this.hashedPhenotypes.get(lookupkey);
        }

        let phenotype = new Phenotype();
        phenotype.lookupkey = lookupkey;
        phenotype.name = generesult;

        phenotype = await this.phenotypeRepository.save(phenotype);
        this.hashedPhenotypes.set(lookupkey, phenotype);

        return phenotype;
    }

    private async clearAllData(): Promise<void> {
        await this.geneSymbolRepository.delete({});
        await this.phenotypeRepository.delete({});
        this.hashedPhenotypes.clear();
    }

    getOneGeneSymbol(options: FindOneOptions<GeneSymbol>): Promise<GeneSymbol> {
        return this.geneSymbolRepository.findOneOrFail(options);
    }

    getOne(options: FindOneOptions<GenePhenotype>): Promise<GenePhenotype> {
        return this.genePhenotypeRepository.findOneOrFail(options);
    }
}
