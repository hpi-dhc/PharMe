import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { FindOneOptions, Repository } from 'typeorm';

import { DiplotypeDto } from './dtos/diplotype.dto';
import { GeneResult } from './entities/gene-result.entity';
import { GeneSymbol } from './entities/gene-symbol.entity';
import { Phenotype } from './entities/phenotype.entity';

@Injectable()
export class PhenotypesService {
    private readonly logger = new Logger(PhenotypesService.name);

    constructor(
        private httpService: HttpService,
        @InjectRepository(GeneSymbol)
        private geneSymbolRepository: Repository<GeneSymbol>,
        @InjectRepository(GeneResult)
        private geneResultRepository: Repository<GeneResult>,
        @InjectRepository(Phenotype)
        private phenotypeRepository: Repository<Phenotype>,
    ) {}

    async fetchPhenotypes(): Promise<void> {
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

        this.savePhenotypes(diplotypeDtos);

        this.logger.log(
            'Successfully saved gene-phenotype combinations to database.',
        );
    }

    findOne(options: FindOneOptions<Phenotype>): Promise<Phenotype> {
        return this.phenotypeRepository.findOneOrFail(options);
    }

    findOneGeneSymbol(
        options: FindOneOptions<GeneSymbol>,
    ): Promise<GeneSymbol> {
        return this.geneSymbolRepository.findOneOrFail(options);
    }

    private async savePhenotypes(
        diplotypeDtos: DiplotypeDto[],
    ): Promise<Phenotype[]> {
        const phenotypes = new Map<string, Phenotype>();
        const geneSymbols = new Map<string, GeneSymbol>();
        const geneResults = new Map<string, GeneResult>();

        for (const dto of diplotypeDtos) {
            // skip entire iteration if phenotype already exists
            const phenotypeId = `${dto.genesymbol}__${dto.generesult}`;
            if (phenotypes.has(phenotypeId)) continue;

            const phenotype = new Phenotype();

            if (!geneSymbols.has(dto.genesymbol)) {
                const geneSymbol = await this.geneSymbolRepository.save({
                    name: dto.genesymbol,
                });
                geneSymbols.set(dto.genesymbol, geneSymbol);
                phenotype.geneSymbol = geneSymbol;
            } else phenotype.geneSymbol = geneSymbols.get(dto.genesymbol);

            if (!geneResults.has(dto.generesult)) {
                const geneResult = await this.geneResultRepository.save({
                    name: dto.generesult,
                });
                geneResults.set(dto.generesult, geneResult);
                phenotype.geneResult = geneResult;
            } else phenotype.geneResult = geneResults.get(dto.generesult);
            phenotype.cpicConsultationText = dto.consultationtext;

            phenotypes.set(phenotypeId, phenotype);
        }
        return await this.phenotypeRepository.save(
            Array.from(phenotypes.values()),
        );
    }

    private async clearAllData(): Promise<void> {
        await this.geneSymbolRepository.delete({});
        await this.geneResultRepository.delete({});
    }
}
