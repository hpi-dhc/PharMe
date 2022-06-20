import { ILike } from 'typeorm';

import { Phenotype } from '../../phenotypes/entities/phenotype.entity';
import { PhenotypesService } from '../../phenotypes/phenotypes.service';
import {
    GuidelineError,
    GuidelineErrorBlame,
    GuidelineErrorType,
} from '../entities/guideline-error.entity';
import { GuidelineCacheMap } from './guideline-cache';

export class PhenotypesByGeneCache extends GuidelineCacheMap<
    Array<Set<Phenotype>>
> {
    private phenotypesService: PhenotypesService;
    private spreadsheetGeneResultHeader: Set<string>[];

    constructor(
        phenotypesService: PhenotypesService,
        spreadsheetGeneResultHeader: Set<string>[],
    ) {
        super();
        this.phenotypesService = phenotypesService;
        this.spreadsheetGeneResultHeader = spreadsheetGeneResultHeader;
    }

    protected async retrieve(
        ...[geneSymbolName]: string[]
    ): Promise<Set<Phenotype>[]> {
        const geneSymbol = await this.phenotypesService.findOneGeneSymbol({
            where: { name: ILike(geneSymbolName) },
            relations: [
                'phenotypes',
                'phenotypes.geneResult',
                'phenotypes.geneSymbol',
            ],
        });
        const phenotypes = this.spreadsheetGeneResultHeader.map(
            (geneResults) =>
                new Set(
                    geneSymbol.phenotypes.filter((phenotype) =>
                        geneResults.has(
                            phenotype.geneResult.name.toLowerCase(),
                        ),
                    ),
                ),
        );
        return phenotypes;
    }

    protected createError(...[geneSymbolName]: string[]): GuidelineError {
        const error = new GuidelineError();
        error.type = GuidelineErrorType.PHENOTYPE_NOT_FOUND;
        error.blame = GuidelineErrorBlame.CPIC;
        error.context = geneSymbolName;
        return error;
    }
}

export class PhenotypesCache extends GuidelineCacheMap<Phenotype> {
    private phenotypesService: PhenotypesService;

    constructor(phenotypesService: PhenotypesService) {
        super();
        this.phenotypesService = phenotypesService;
    }

    protected async retrieve(
        ...[geneSymbolName, geneResultName]: string[]
    ): Promise<Phenotype> {
        return this.phenotypesService.findOne({
            where: {
                geneSymbol: { name: ILike(geneSymbolName) },
                geneResult: { name: geneResultName },
            },
            relations: ['geneResult', 'geneSymbol'],
        });
    }

    protected createError(
        ...[geneSymbolName, geneResultName]: string[]
    ): GuidelineError {
        const error = new GuidelineError();
        error.type = GuidelineErrorType.PHENOTYPE_NOT_FOUND;
        error.blame = GuidelineErrorBlame.CPIC;
        error.context = `${geneSymbolName}:${geneResultName}`;
        return error;
    }
}
