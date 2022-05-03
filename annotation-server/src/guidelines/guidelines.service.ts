import { assert } from 'console';

import { sheets_v4 } from '@googleapis/sheets';
import { HttpService } from '@nestjs/axios';
import {
    Injectable,
    InternalServerErrorException,
    Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { lastValueFrom } from 'rxjs';
import { ILike, Repository } from 'typeorm';

import { fetchSpreadsheetCells } from '../common/google-sheets';
import { GenePhenotype } from '../gene-phenotypes/entities/gene-phenotype.entity';
import { GenePhenotypesService } from '../gene-phenotypes/gene-phenotypes.service';
import { Medication } from '../medications/medication.entity';
import { MedicationsService } from '../medications/medications.service';
import { CpicRecommendationDto } from './dtos/cpic-recommendation.dto';
import { Guideline, WarningLevel } from './guideline.entity';

@Injectable()
export class GuidelinesService {
    private readonly logger = new Logger(GuidelinesService.name);
    private hashedMedicationsByName: Map<string, Medication>;
    private hashedMedicationsByRxCUI: Map<string, Medication>;
    private hashedGenePhenotypes: Map<string, Array<Set<GenePhenotype>>>;
    private spreadsheetPhenotypeHeader: Array<Set<string>>;

    constructor(
        private configService: ConfigService,
        private httpService: HttpService,
        @InjectRepository(Guideline)
        private guidelinesRepository: Repository<Guideline>,
        private medicationsService: MedicationsService,
        private genePhenotypesService: GenePhenotypesService,
    ) {
        this.hashedGenePhenotypes = new Map();
        this.hashedMedicationsByName = new Map();
        this.hashedMedicationsByRxCUI = new Map();
        this.spreadsheetPhenotypeHeader = [];
    }

    async fetchGuidelines(): Promise<void> {
        await this.clearAllData();
        const guidelines = await this.fetchCpicGuidelines();
        await this.complementAndSaveGuidelines(guidelines);
    }

    async complementAndSaveGuidelines(
        guidelines: Map<string, Guideline[]>,
    ): Promise<void> {
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

        this.spreadsheetPhenotypeHeader = phenotypeHeader[0].map(
            (cell) =>
                new Set(
                    cell.value
                        .split(';')
                        .map((phenotype) => phenotype.trim().toLowerCase()),
                ),
        );
        for (let row = 0; row < medications.length; row++) {
            const geneSymbolName = genes[row]?.[0];
            const medicationName = medications[row]?.[0];
            if (!geneSymbolName || !medicationName) continue;

            const medication = await this.findMedicationByName(
                medicationName.value,
            );
            const genePhenotypes = await this.findGenePhenotypes(
                geneSymbolName.value,
            );
            if (genePhenotypes.length === 0 || !medication) continue;

            for (let col = 0; col < implications[row].length; col++) {
                for (const genePhenotype of genePhenotypes[col].values()) {
                    const guidelinesForMedication = guidelines.get(
                        medication.name,
                    );
                    const guidelinesForGenePhenotype =
                        guidelinesForMedication.filter(
                            (guidelineForMed) =>
                                guidelineForMed.genePhenotype.id ===
                                genePhenotype.id,
                        );
                    if (!guidelinesForGenePhenotype.length)
                        throw new InternalServerErrorException(
                            `No matching CPIC guideline was found for ${medication.name} and genephenotype ${genePhenotype.geneSymbol}, ${genePhenotype.phenotype.name}!`,
                        );
                    for (const guideline of guidelinesForGenePhenotype) {
                        const implication =
                            implications[row][col].value?.trim();
                        const recommendation =
                            recommendations[row][col].value?.trim();
                        const warningLevel = this.getWarningLevelFromColor(
                            recommendations[row][col].backgroundColor,
                        );
                        if (
                            !implication ||
                            implication.replace(' ', '').toLowerCase() ===
                                'n/a' ||
                            !recommendation ||
                            recommendation.replace(' ', '').toLowerCase() ===
                                'n/a'
                        ) {
                            continue;
                        }
                        guideline.implication = implication;
                        guideline.recommendation = recommendation;
                        guideline.warningLevel = warningLevel;
                    }
                }
            }
        }
        const flatGuidelines = Array.from(guidelines.values()).flat();

        const incompleteGuidelines =
            this.getIncompleteGuidelines(flatGuidelines);
        for (const incompleteGuideline of incompleteGuidelines) {
            this.logger.error(
                `Guideline for ${incompleteGuideline.medication.name} for genephenotype ${incompleteGuideline.genePhenotype.geneSymbol.name}, ${incompleteGuideline.genePhenotype.phenotype.name} is missing from sheet!`,
            );
        }

        this.guidelinesRepository.save(flatGuidelines);

        this.clearMaps();
    }

    async fetchCpicGuidelines(): Promise<Map<string, Guideline[]>> {
        const response = this.httpService.get(
            'https://api.cpicpgx.org/v1/recommendation',
            {
                params: {
                    select: 'drugid,drugrecommendation,implications,comments,phenotypes,lookupkey,classification',
                },
            },
        );
        const recommendationDtos: CpicRecommendationDto[] = (
            await lastValueFrom(response)
        ).data;

        const guidelines: Map<string, Guideline[]> = new Map();

        for (const cpicRecommendationDto of recommendationDtos) {
            const externalid = cpicRecommendationDto.drugid.split(':');
            if (externalid[0] !== 'RxNorm') continue;
            const medication = await this.findMedicationByRxNorm(externalid[1]);
            if (!medication) continue;
            for (const [geneSymbol, lookupkey] of Object.entries(
                cpicRecommendationDto.lookupkey,
            )) {
                const genePhenotype = await this.findGenePhenotype(
                    geneSymbol,
                    lookupkey,
                );
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
        }
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

    private async findMedicationByName(name: string): Promise<Medication> {
        if (!name) return null;
        name = name.trim().toLowerCase();
        if (this.hashedMedicationsByName.has(name)) {
            return this.hashedMedicationsByName.get(name);
        }
        try {
            const medication = await this.medicationsService.getOne({
                where: { name: ILike(name) },
            });

            this.hashedMedicationsByName.set(name, medication);
            this.hashedMedicationsByRxCUI.set(medication.rxcui, medication);
            return medication;
        } catch (error) {
            // TODO: consider proper error handling
            this.logger.error(`Medication ${name} not found in Drugbank data.`);
            this.hashedMedicationsByName.set(name, null);
            return null;
        }
    }

    private async findMedicationByRxNorm(rxcui: string): Promise<Medication> {
        if (this.hashedMedicationsByRxCUI.has(rxcui)) {
            return this.hashedMedicationsByRxCUI.get(rxcui);
        }
        try {
            const medication = await this.medicationsService.getOne({
                where: {
                    rxcui,
                },
            });
            this.hashedMedicationsByRxCUI.set(rxcui, medication);
            this.hashedMedicationsByName.set(medication.name, medication);
            return medication;
        } catch (error) {
            this.logger.error(
                `Medication with RxCUI ${rxcui} not found in our database.`,
            );
            return null;
        }
    }

    private async findGenePhenotype(
        geneSymbolName: string,
        lookupkey: string,
    ): Promise<GenePhenotype> {
        if (!geneSymbolName || !lookupkey) return null;
        geneSymbolName = geneSymbolName.trim().toLowerCase();
        const genePhenotype =
            await this.genePhenotypesService.getOneGenePhenotype({
                where: {
                    geneSymbol: { name: ILike(geneSymbolName) },
                    phenotype: { lookupkey },
                },
                relations: ['phenotype', 'geneSymbol'],
            });
        return genePhenotype;
    }

    private async findGenePhenotypes(
        geneSymbolName: string,
    ): Promise<Array<Set<GenePhenotype>>> {
        if (!geneSymbolName) return [];
        geneSymbolName = geneSymbolName.trim().toLowerCase();
        if (this.hashedGenePhenotypes.has(geneSymbolName)) {
            return this.hashedGenePhenotypes.get(geneSymbolName);
        }
        const geneSymbol = await this.genePhenotypesService.getOne({
            where: { name: ILike(geneSymbolName) },
            relations: ['genePhenotypes', 'genePhenotypes.phenotype'],
        });
        // TODO: consider proper error handling
        if (!geneSymbol) {
            this.logger.error(
                `Gene ${geneSymbolName.toUpperCase()} not found in CPIC lookupkeys.`,
            );
            this.hashedGenePhenotypes.set(geneSymbolName, []);
            return [];
        }
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
        this.hashedGenePhenotypes.set(geneSymbolName, genePhenotypes);
        return genePhenotypes;
    }

    private getIncompleteGuidelines(guidelines: Guideline[]): Guideline[] {
        const incompleteGuidelines: Guideline[] = [];
        for (const guideline of guidelines) {
            if (!guideline.implication && !guideline.recommendation)
                incompleteGuidelines.push(guideline);
        }
        return incompleteGuidelines;
    }

    async clearAllData(): Promise<void> {
        this.guidelinesRepository.delete({});
        this.clearMaps();
    }

    private clearMaps(): void {
        this.hashedMedicationsByName.clear();
        this.hashedMedicationsByRxCUI.clear();
        this.hashedGenePhenotypes.clear();
        this.spreadsheetPhenotypeHeader = [];
    }
}
