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

    private hashedGeneSymbols: Map<string, GeneSymbol>;
    private hashedPhenotypes: Map<string, Phenotype>;

    constructor(
        private httpService: HttpService,
        @InjectRepository(GeneSymbol)
        private geneSymbolRepository: Repository<GeneSymbol>,
        @InjectRepository(Phenotype)
        private phenotypeRepository: Repository<Phenotype>,
        @InjectRepository(GenePhenotype)
        private genePhenotypeRepository: Repository<GenePhenotype>,
    ) {
        this.hashedGeneSymbols = new Map();
        this.hashedPhenotypes = new Map();
    }

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

        await this.genePhenotypeRepository.save(
            await this.getGenePhenotypes(diplotypeDtos),
        );

        this.hashedGeneSymbols.clear();
        this.hashedPhenotypes.clear();
        this.logger.log(
            'Successfully saved gene-phenotype combinations to database.',
        );
    }

    private async getGenePhenotypes(
        diplotypeDtos: DiplotypeDto[],
    ): Promise<GenePhenotype[]> {
        const genePhenotypes = new Map<string, GenePhenotype>();

        for (const diplotypeDto of diplotypeDtos) {
            const key = [diplotypeDto.genesymbol, diplotypeDto.generesult].join(
                ';',
            );

            if (genePhenotypes.has(key)) {
                continue;
            }

            const geneSymbol = await this.findOrCreateGeneSymbol(
                diplotypeDto.genesymbol,
            );
            const phenotype = await this.findOrCreatePhenotype(
                diplotypeDto.generesult,
            );

            const genePhenotype = new GenePhenotype();
            genePhenotype.geneSymbol = geneSymbol;
            genePhenotype.phenotype = phenotype;
            genePhenotype.cpicConsultationText = diplotypeDto.consultationtext;

            genePhenotypes.set(key, genePhenotype);
        }

        return Array.from(genePhenotypes.values());
    }

    private async findOrCreateGeneSymbol(
        genesymbol: string,
    ): Promise<GeneSymbol> {
        if (this.hashedGeneSymbols.has(genesymbol)) {
            return this.hashedGeneSymbols.get(genesymbol);
        }

        const geneSymbol = new GeneSymbol();
        geneSymbol.name = genesymbol;

        const storedGeneSymbol = await this.geneSymbolRepository.save(
            geneSymbol,
        );
        this.hashedGeneSymbols.set(genesymbol, storedGeneSymbol);

        return storedGeneSymbol;
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
        this.hashedGeneSymbols.clear();
        this.hashedPhenotypes.clear();
    }

    getOneGeneSymbol(options: FindOneOptions<GeneSymbol>): Promise<GeneSymbol> {
        return this.geneSymbolRepository.findOneOrFail(options);
    }

    getOne(options: FindOneOptions<GenePhenotype>): Promise<GenePhenotype> {
        return this.genePhenotypeRepository.findOneOrFail(options);
    }
}
