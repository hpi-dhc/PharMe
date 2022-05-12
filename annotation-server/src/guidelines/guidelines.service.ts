import { sheets_v4 } from '@googleapis/sheets';
import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { Repository } from 'typeorm';

import { fetchSpreadsheetCells } from '../common/google-sheets';
import { GenePhenotype } from '../gene-phenotypes/entities/gene-phenotype.entity';
import { GenePhenotypesService } from '../gene-phenotypes/gene-phenotypes.service';
import { Medication } from '../medications/medication.entity';
import { MedicationsService } from '../medications/medications.service';
import {
    GenePhenotypesByGeneCache,
    GenePhenotypesCache,
} from './caches/gene-phenotype-caches';
import {
    MedicationByNameCache,
    MedicationByRxcuiCache,
} from './caches/medication-caches';
import { CpicRecommendationDto } from './dtos/cpic-recommendation.dto';
import {
    GuidelineError,
    GuidelineErrorBlame,
    GuidelineErrorType,
} from './entities/guideline-error.entity';
import { Guideline, WarningLevel } from './entities/guideline.entity';

@Injectable()
export class GuidelinesService {
    private readonly logger = new Logger(GuidelinesService.name);
    private spreadsheetPhenotypeHeader: Array<Set<string>>;
    private medicationsByNameCache: MedicationByNameCache;
    private medicationsByRxcuiCache: MedicationByRxcuiCache;
    private genePhenotypesByGeneCache: GenePhenotypesByGeneCache;
    private genePhenotypesCache: GenePhenotypesCache;

    constructor(
        private configService: ConfigService,
        private httpService: HttpService,
        @InjectRepository(Guideline)
        private guidelinesRepository: Repository<Guideline>,
        @InjectRepository(GuidelineError)
        private guidelineErrorRepository: Repository<GuidelineError>,
        private medicationsService: MedicationsService,
        private genePhenotypesService: GenePhenotypesService,
    ) {
        this.spreadsheetPhenotypeHeader = [];
        this.medicationsByNameCache = new MedicationByNameCache(
            this.medicationsService,
        );
        this.medicationsByRxcuiCache = new MedicationByRxcuiCache(
            this.medicationsService,
        );
        this.genePhenotypesByGeneCache = new GenePhenotypesByGeneCache(
            this.genePhenotypesService,
            this.spreadsheetPhenotypeHeader,
        );
        this.genePhenotypesCache = new GenePhenotypesCache(
            this.genePhenotypesService,
        );
    }

    async fetchGuidelines(): Promise<void> {
        await this.clearAllData();
        const guidelines = await this.fetchCpicGuidelines();
        await this.complementAndSaveGuidelines(guidelines);
    }

    async complementAndSaveGuidelines(
        guidelines: Map<string, Guideline[]>,
    ): Promise<void> {
        this.logger.log('Complementing CPIC guidelines with data from sheet.');
        const [
            medications,
            genes,
            phenotypeHeader,
            implications,
            recommendations,
        ] = await fetchSpreadsheetCells(
            this.configService.get<string>('GOOGLESHEET_ID'),
            this.configService.get<string>('GOOGLESHEET_APIKEY'),
            [
                this.configService.get<string>('GOOGLESHEET_RANGE_MEDICATIONS'),
                this.configService.get<string>('GOOGLESHEET_RANGE_GENES'),
                this.configService.get<string>('GOOGLESHEET_RANGE_PHENOTYPES'),
                this.configService.get<string>(
                    'GOOGLESHEET_RANGE_IMPLICATIONS',
                ),
                this.configService.get<string>(
                    'GOOGLESHEET_RANGE_RECOMMENDATIONS',
                ),
            ],
        );

        this.spreadsheetPhenotypeHeader.splice(
            0,
            this.spreadsheetPhenotypeHeader.length,
            ...phenotypeHeader[0].map(
                (cell) =>
                    new Set(
                        cell.value
                            .split(';')
                            .map((phenotype) => phenotype.trim().toLowerCase()),
                    ),
            ),
        );

        const guidelineErrors: Set<GuidelineError> = new Set();
        for (let row = 0; row < medications.length; row++) {
            // parse all lines in sheet
            const geneSymbolName = genes[row]?.[0];
            const medicationName = medications[row]?.[0];
            if (!geneSymbolName || !medicationName || !medicationName.value) {
                continue;
            }

            try {
                const medication = await this.medicationsByNameCache.get(
                    medicationName.value,
                );
                const genePhenotypes = await this.genePhenotypesByGeneCache.get(
                    geneSymbolName.value,
                );
                if (genePhenotypes.length === 0) continue;

                const guidelinesForMedication = guidelines.get(medication.name);

                for (let col = 0; col < implications[row].length; col++) {
                    const implication = implications[row][col].value?.trim();
                    const recommendation =
                        recommendations[row][col].value?.trim();
                    const warningLevel = this.getWarningLevelFromColor(
                        recommendations[row][col].backgroundColor,
                    );
                    if (
                        !this.guidelineTextsAreValid(
                            implication,
                            recommendation,
                        )
                    ) {
                        continue;
                    }
                    // supplement guidelines with implications and recommendations from sheet
                    for (const genePhenotype of genePhenotypes[col].values()) {
                        try {
                            const guidelinesForGenePhenotype =
                                this.getGuidelinesForGenePhenotype(
                                    medication,
                                    genePhenotype,
                                    guidelinesForMedication,
                                );
                            guidelinesForGenePhenotype.forEach((guideline) => {
                                guideline.implication = implication;
                                guideline.recommendation = recommendation;
                                guideline.warningLevel = warningLevel;
                            });
                        } catch (error) {
                            guidelineErrors.add(error);
                        }
                    }
                }
            } catch (error) {
                if (error instanceof GuidelineError) {
                    guidelineErrors.add(error);
                } else throw error;
                continue;
            }
        }
        const flatGuidelines = Array.from(guidelines.values()).flat();

        const incompleteGuidelines = flatGuidelines.filter(
            (guideline) => !guideline.isComplete,
        );
        for (const incompleteGuideline of incompleteGuidelines) {
            const error = new GuidelineError();
            error.type = GuidelineErrorType.GUIDELINE_MISSING_FROM_SHEET;
            error.blame = GuidelineErrorBlame.SHEET;
            incompleteGuideline.errors.push(error);
        }

        this.guidelinesRepository.save(flatGuidelines);
        this.guidelineErrorRepository.save(Array.from(guidelineErrors));

        this.clearCaches();
        this.logger.log('Successfully saved all valid guidelines.');
    }

    async fetchCpicGuidelines(): Promise<Map<string, Guideline[]>> {
        this.logger.log('Fetching guidelines from CPIC.');
        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/recommendation',
            {
                params: {
                    select: 'drugid,drugrecommendation,implications,comments,phenotypes,classification',
                },
            },
        );
        const recommendationDtos: CpicRecommendationDto[] = (
            await lastValueFrom(response)
        ).data;

        const guidelines: Map<string, Guideline[]> = new Map();
        const guidelineErrors: Set<GuidelineError> = new Set();

        const knownCombinations: Set<string> = new Set();
        for (const cpicRecommendationDto of recommendationDtos) {
            const externalid = cpicRecommendationDto.drugid.split(':');
            if (externalid[0] !== 'RxNorm') continue;
            try {
                const medication = await this.medicationsByRxcuiCache.get(
                    externalid[1],
                );
                if (!medication) continue;
                for (const [geneSymbol, phenotype] of Object.entries(
                    cpicRecommendationDto.phenotypes,
                )) {
                    const genePhenotype = await this.genePhenotypesCache.get(
                        geneSymbol,
                        phenotype,
                    );
                    if (!genePhenotype) continue;
                    const knownKey = `${medication.id}:${genePhenotype.id}`;
                    if (knownCombinations.has(knownKey)) continue;
                    knownCombinations.add(knownKey);
                    const guideline = Guideline.fromCpicRecommendation(
                        cpicRecommendationDto,
                        medication,
                        genePhenotype,
                    );

                    if (guidelines.has(medication.name)) {
                        guidelines.get(medication.name).push(guideline);
                    } else {
                        guidelines.set(medication.name, [guideline]);
                    }
                }
            } catch (error) {
                if (error instanceof GuidelineError) {
                    guidelineErrors.add(error);
                } else throw error;
                continue;
            }
        }
        this.guidelineErrorRepository.save(Array.from(guidelineErrors));
        this.logger.log('Successfully fetched guidelines from CPIC.');
        return guidelines;
    }

    private getWarningLevelFromColor(
        color?: sheets_v4.Schema$Color,
    ): WarningLevel | null {
        if (!color) return null;
        const [red, green, blue] = [color.red, color.green, color.blue];
        if (!red && green === 1 && !blue) return WarningLevel.GREEN;
        if (red === 1 && green === 1 && !blue) return WarningLevel.YELLOW;
        if (red === 1 && !green && !blue) return WarningLevel.RED;
        if (red === green && red === blue && blue === green) return null; // any shade of gray or transparent/unset background (undefined)
        this.logger.warn('Sheet cell has unknown color');
        return null;
    }

    private guidelineTextsAreValid(
        implication: string,
        recommendation: string,
    ): boolean {
        return (
            implication &&
            implication.replace(' ', '').toLowerCase() !== 'n/a' &&
            recommendation &&
            recommendation.replace(' ', '').toLowerCase() !== 'n/a'
        );
    }

    private getGuidelinesForGenePhenotype(
        medication: Medication,
        genePhenotype: GenePhenotype,
        guidelinesForMed: Guideline[],
    ): Guideline[] {
        const guidelinesForGenePhenotype = guidelinesForMed?.filter(
            (guidelineForMed) =>
                guidelineForMed.genePhenotype.id === genePhenotype.id,
        );
        if (!guidelinesForGenePhenotype?.length) {
            const error = new GuidelineError();
            error.type = GuidelineErrorType.GUIDELINE_MISSING_FROM_CPIC;
            error.blame = GuidelineErrorBlame.CPIC;
            error.context = `${medication.name}, ${genePhenotype.geneSymbol.name}:${genePhenotype.phenotype.name}`;
            throw error;
        }
        return guidelinesForGenePhenotype;
    }

    async clearAllData(): Promise<void> {
        this.guidelinesRepository.delete({});
        this.guidelineErrorRepository.delete({});
        this.clearCaches();
    }

    private clearCaches(): void {
        this.medicationsByNameCache.clear();
        this.medicationsByRxcuiCache.clear();
        this.genePhenotypesByGeneCache.clear();
        this.genePhenotypesCache.clear();
        this.spreadsheetPhenotypeHeader.splice(
            0,
            this.spreadsheetPhenotypeHeader.length,
        );
    }

    async getAllErrors(): Promise<GuidelineError[]> {
        return this.guidelineErrorRepository.find({
            select: {
                type: true,
                context: true,
                blame: true,
                guideline: { id: true },
            },
            relations: ['guideline'],
        });
    }
}
