import { sheets_v4 } from '@googleapis/sheets';
import { HttpService } from '@nestjs/axios';
import { HttpException, HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { FindOptionsOrder, FindOptionsOrderValue, Repository } from 'typeorm';

import { fetchSpreadsheetCells } from '../common/utils/google-sheets';
import { FetchTarget } from '../fetch-dates/fetch-date.entity';
import { FetchDatesService } from '../fetch-dates/fetch-dates.service';
import { Medication } from '../medications/medication.entity';
import { MedicationsService } from '../medications/medications.service';
import { Phenotype } from '../phenotypes/entities/phenotype.entity';
import { PhenotypesService } from '../phenotypes/phenotypes.service';
import {
    MedicationByNameCache,
    MedicationByRxcuiCache,
} from './caches/medication-caches';
import {
    PhenotypesByGeneCache,
    PhenotypesCache,
} from './caches/phenotype-caches';
import { CpicGuidelineDto } from './dtos/cpic-guideline.dto';
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
    private spreadsheetGeneResultHeader: Array<Set<string>>;
    private medicationsByNameCache: MedicationByNameCache;
    private medicationsByRxcuiCache: MedicationByRxcuiCache;
    private phenotypesByGeneCache: PhenotypesByGeneCache;
    private phenotypesCache: PhenotypesCache;

    constructor(
        private configService: ConfigService,
        private httpService: HttpService,
        @InjectRepository(Guideline)
        private guidelinesRepository: Repository<Guideline>,
        @InjectRepository(GuidelineError)
        private guidelineErrorRepository: Repository<GuidelineError>,
        private medicationsService: MedicationsService,
        private phenotypesService: PhenotypesService,
        private fetchDatesService: FetchDatesService,
    ) {
        this.spreadsheetGeneResultHeader = [];
        this.medicationsByNameCache = new MedicationByNameCache(
            this.medicationsService,
        );
        this.medicationsByRxcuiCache = new MedicationByRxcuiCache(
            this.medicationsService,
        );
        this.phenotypesByGeneCache = new PhenotypesByGeneCache(
            this.phenotypesService,
            this.spreadsheetGeneResultHeader,
        );
        this.phenotypesCache = new PhenotypesCache(this.phenotypesService);
    }

    async findAll(
        limit: number,
        offset: number,
        order: FindOptionsOrder<Guideline>,
    ): Promise<Guideline[]> {
        return this.guidelinesRepository.find({
            select: {
                id: true,
                implication: true,
                recommendation: true,
                warningLevel: true,
                medication: { name: true },
                phenotype: {
                    id: true,
                    geneSymbol: { name: true },
                    geneResult: { name: true },
                },
            },
            take: limit,
            skip: offset,
            order,
            relations: {
                medication: true,
                phenotype: {
                    geneSymbol: true,
                    geneResult: true,
                },
            },
        });
    }

    async findOne(id: number): Promise<Guideline> {
        return this.guidelinesRepository.findOneOrFail({
            where: { id },
            relations: {
                medication: true,
                phenotype: {
                    geneSymbol: true,
                    geneResult: true,
                },
            },
        });
    }

    async findAllErrors(
        limit: number,
        offset: number,
        sortBy: string,
        orderBy: FindOptionsOrderValue,
    ): Promise<GuidelineError[]> {
        return this.guidelineErrorRepository.find({
            take: limit,
            skip: offset,
            order: { [sortBy]: orderBy },
            relations: ['guideline'],
        });
    }

    async fetchGuidelines(): Promise<void> {
        if (!(await this.medicationsService.hasData())) {
            throw new HttpException(
                {
                    status: HttpStatus.BAD_REQUEST,
                    error: 'Medication data has to be initialized.',
                },
                HttpStatus.BAD_REQUEST,
            );
        }
        await this.phenotypesService.fetchPhenotypes();
        await this.clearAllData();
        const guidelines = await this.fetchCpicGuidelines();
        await this.addGuidelineURLS(guidelines);
        await this.complementAndSaveGuidelines(guidelines);
        await this.fetchDatesService.set(FetchTarget.GUIDELINES);
    }

    async getLastUpdate(): Promise<Date | null> {
        return this.fetchDatesService.get(FetchTarget.GUIDELINES);
    }

    private async fetchCpicGuidelines(): Promise<Map<string, Guideline[]>> {
        this.logger.log('Fetching guidelines from CPIC.');
        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/recommendation',
            {
                params: {
                    select: [
                        'drugid',
                        'drugrecommendation',
                        'implications',
                        'comments',
                        'phenotypes',
                        'classification',
                        'guidelineid',
                    ].join(','),
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
            if (
                cpicRecommendationDto.classification.match(/no recommendation/i)
            ) {
                continue;
            }
            const externalid = cpicRecommendationDto.drugid.split(':');
            if (externalid[0] !== 'RxNorm') continue;
            try {
                const medication = await this.medicationsByRxcuiCache.get(
                    externalid[1],
                );
                if (!medication) continue;
                for (const [geneSymbol, geneResult] of Object.entries(
                    cpicRecommendationDto.phenotypes,
                )) {
                    const phenotype = await this.phenotypesCache.get(
                        geneSymbol,
                        geneResult,
                    );
                    if (!phenotype) continue;
                    const knownKey = `${medication.id}:${phenotype.id}`;
                    if (knownCombinations.has(knownKey)) continue;
                    knownCombinations.add(knownKey);
                    const guideline = Guideline.fromCpicRecommendation(
                        cpicRecommendationDto,
                        medication,
                        phenotype,
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

    private async addGuidelineURLS(
        guidelines: Map<string, Guideline[]>,
    ): Promise<Map<string, Guideline[]>> {
        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/guideline',
            {
                params: {
                    select: ['id', 'name', 'url'].join(','),
                },
            },
        );
        const guidelineDtos: CpicGuidelineDto[] = (
            await lastValueFrom(response)
        ).data;
        const guidelineDtoById: Map<number, CpicGuidelineDto> = new Map();
        guidelineDtos.forEach((guidelineDto) =>
            guidelineDtoById.set(guidelineDto.id, guidelineDto),
        );
        for (const guidelinesForMedication of guidelines.values()) {
            guidelinesForMedication.forEach((guideline) => {
                const guidelineDto = guidelineDtoById.get(
                    guideline.cpicGuidelineId,
                );
                guideline.cpicGuidelineUrl = guidelineDto.url;
                guideline.cpicGuidelineName = guidelineDto.name;
            });
        }
        return guidelines;
    }

    private async complementAndSaveGuidelines(
        guidelines: Map<string, Guideline[]>,
    ): Promise<void> {
        this.logger.log('Complementing CPIC guidelines with data from sheet.');
        const [
            medications,
            genes,
            geneResultHeader,
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

        this.spreadsheetGeneResultHeader.splice(
            0,
            this.spreadsheetGeneResultHeader.length,
            ...geneResultHeader[0].map(
                (cell) =>
                    new Set(
                        cell.value
                            .split(';')
                            .map((geneResult) =>
                                geneResult.trim().toLowerCase(),
                            ),
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
                const phenotypes = await this.phenotypesByGeneCache.get(
                    geneSymbolName.value,
                );
                if (phenotypes.length === 0) continue;

                const guidelinesForMedication = guidelines.get(medication.name);

                for (let col = 0; col < implications[row].length; col++) {
                    const implication = implications[row][col].value?.trim();
                    const recommendation =
                        recommendations[row][col].value?.trim();
                    const warningLevel = this.warningLevelFromColor(
                        recommendations[row][col].backgroundColor,
                    );
                    if (
                        this.isInvalidText(implication) ||
                        this.isInvalidText(recommendation)
                    ) {
                        continue;
                    }
                    // supplement guidelines with implications and recommendations from sheet
                    for (const phenotype of phenotypes[col].values()) {
                        try {
                            const guidelinesForPhenotype =
                                this.getGuidelinesForPhenotype(
                                    medication,
                                    phenotype,
                                    guidelinesForMedication,
                                );
                            guidelinesForPhenotype.forEach((guideline) => {
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
            (guideline) => guideline.isIncomplete,
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

    private isInvalidText(text: string): boolean {
        text = text.replace(' ', '');
        return !(text && text.toLowerCase() !== 'n/a');
    }

    private getGuidelinesForPhenotype(
        medication: Medication,
        phenotype: Phenotype,
        guidelinesForMed: Guideline[],
    ): Guideline[] {
        const guidelinesForPhenotype = guidelinesForMed?.filter(
            (guidelineForMed) => guidelineForMed.phenotype.id === phenotype.id,
        );
        if (!guidelinesForPhenotype?.length) {
            const error = new GuidelineError();
            error.type = GuidelineErrorType.GUIDELINE_MISSING_FROM_CPIC;
            error.blame = GuidelineErrorBlame.CPIC;
            error.context = `${medication.name}, ${phenotype.geneSymbol.name}:${phenotype.geneResult.name}`;
            throw error;
        }
        return guidelinesForPhenotype;
    }

    async clearAllData(): Promise<void> {
        this.guidelinesRepository.delete({});
        this.guidelineErrorRepository.delete({});
        this.clearCaches();
    }

    private clearCaches(): void {
        this.medicationsByNameCache.clear();
        this.medicationsByRxcuiCache.clear();
        this.phenotypesByGeneCache.clear();
        this.phenotypesCache.clear();
        this.spreadsheetGeneResultHeader.splice(
            0,
            this.spreadsheetGeneResultHeader.length,
        );
    }

    private warningLevelFromColor(
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
}
