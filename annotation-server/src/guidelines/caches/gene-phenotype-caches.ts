import { ILike } from 'typeorm';

import { GenePhenotype } from '../../gene-phenotypes/entities/gene-phenotype.entity';
import { GenePhenotypesService } from '../../gene-phenotypes/gene-phenotypes.service';
import {
    GuidelineError,
    GuidelineErrorBlame,
    GuidelineErrorType,
} from '../entities/guideline-error.entity';
import { GuidelineCacheMap } from './guideline-cache';

export class GenePhenotypesByGeneCache extends GuidelineCacheMap<
    Array<Set<GenePhenotype>>
> {
    private genePhenotypesService: GenePhenotypesService;
    private spreadsheetPhenotypeHeader: Set<string>[];

    constructor(
        genePhenotypeService: GenePhenotypesService,
        spreadsheetPhenotypeHeader: Set<string>[],
    ) {
        super();
        this.genePhenotypesService = genePhenotypeService;
        this.spreadsheetPhenotypeHeader = spreadsheetPhenotypeHeader;
    }

    protected async retrieve(
        ...[geneSymbolName]: string[]
    ): Promise<Set<GenePhenotype>[]> {
        const geneSymbol = await this.genePhenotypesService.findOneGeneSymbol({
            where: { name: ILike(geneSymbolName) },
            relations: [
                'genePhenotypes',
                'genePhenotypes.phenotype',
                'genePhenotypes.geneSymbol',
            ],
        });
        const genePhenotypes = this.spreadsheetPhenotypeHeader.map(
            (phenotypes) =>
                new Set(
                    geneSymbol.genePhenotypes.filter((genePhenotype) =>
                        phenotypes.has(
                            genePhenotype.phenotype.name.toLowerCase(),
                        ),
                    ),
                ),
        );
        return genePhenotypes;
    }

    protected createError(...[geneSymbolName]: string[]): GuidelineError {
        const error = new GuidelineError();
        error.type = GuidelineErrorType.GENEPHENOTYPE_NOT_FOUND;
        error.blame = GuidelineErrorBlame.CPIC;
        error.context = geneSymbolName;
        return error;
    }
}

export class GenePhenotypesCache extends GuidelineCacheMap<GenePhenotype> {
    private genePhenotypesService: GenePhenotypesService;

    constructor(genePhenotypeService: GenePhenotypesService) {
        super();
        this.genePhenotypesService = genePhenotypeService;
    }

    protected async retrieve(
        ...[geneSymbolName, phenotype]: string[]
    ): Promise<GenePhenotype> {
        return this.genePhenotypesService.findOne({
            where: {
                geneSymbol: { name: ILike(geneSymbolName) },
                phenotype: { name: phenotype },
            },
            relations: ['phenotype', 'geneSymbol'],
        });
    }

    protected createError(
        ...[geneSymbolName, phenotype]: string[]
    ): GuidelineError {
        const error = new GuidelineError();
        error.type = GuidelineErrorType.GENEPHENOTYPE_NOT_FOUND;
        error.blame = GuidelineErrorBlame.CPIC;
        error.context = `${geneSymbolName}:${phenotype}`;
        return error;
    }
}
