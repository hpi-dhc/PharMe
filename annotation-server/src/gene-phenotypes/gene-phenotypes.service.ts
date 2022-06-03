import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { FindOneOptions, Repository } from 'typeorm';

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
    ) {}

    async fetchGenePhenotypes(): Promise<void> {
        await this.clearAllData();

        this.logger.log('Fetching gene-phenotype combinations from CPIC.');
        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/diplotype',
            {
                params: {
                    select: [
                        'genesymbol',
                        'generesult',
                        'consultationtext',
                    ].join(','),
                },
            },
        );

        const diplotypeDtos: DiplotypeDto[] = (await lastValueFrom(response))
            .data;

        this.saveGenePhenotypes(diplotypeDtos);

        this.logger.log(
            'Successfully saved gene-phenotype combinations to database.',
        );
    }

    findOne(options: FindOneOptions<GenePhenotype>): Promise<GenePhenotype> {
        return this.genePhenotypeRepository.findOneOrFail(options);
    }

    findOneGeneSymbol(
        options: FindOneOptions<GeneSymbol>,
    ): Promise<GeneSymbol> {
        return this.geneSymbolRepository.findOneOrFail(options);
    }

    private async saveGenePhenotypes(
        diplotypeDtos: DiplotypeDto[],
    ): Promise<GenePhenotype[]> {
        const genePhenotypes = new Map<string, GenePhenotype>();
        const geneSymbols = new Map<string, GeneSymbol>();
        const phenotypes = new Map<string, Phenotype>();

        for (const dto of diplotypeDtos) {
            // skip entire iteration if genephenotype already exists
            const genePhenotypeId = `${dto.genesymbol}__${dto.generesult}`;
            if (genePhenotypes.has(genePhenotypeId)) continue;

            const genePhenotype = new GenePhenotype();

            if (!geneSymbols.has(dto.genesymbol)) {
                const geneSymbol = await this.geneSymbolRepository.save({
                    name: dto.genesymbol,
                });
                geneSymbols.set(dto.genesymbol, geneSymbol);
            }
            genePhenotype.geneSymbol = geneSymbols.get(dto.genesymbol);

            if (!phenotypes.has(dto.generesult)) {
                const phenotype = await this.phenotypeRepository.save({
                    name: dto.generesult,
                });
                phenotypes.set(dto.generesult, phenotype);
            }
            genePhenotype.phenotype = phenotypes.get(dto.generesult);
            genePhenotype.cpicConsultationText = dto.consultationtext;

            genePhenotypes.set(genePhenotypeId, genePhenotype);
        }
        return await this.genePhenotypeRepository.save(
            Array.from(genePhenotypes.values()),
        );
    }

    private async clearAllData(): Promise<void> {
        await this.geneSymbolRepository.delete({});
        await this.phenotypeRepository.delete({});
    }
}
