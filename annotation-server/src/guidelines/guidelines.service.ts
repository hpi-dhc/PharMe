import { sheets_v4 } from '@googleapis/sheets';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';

import { fetchSpreadsheetCells } from '../common/google-sheets';
import { GenePhenotype } from '../gene-phenotypes/entities/gene-phenotype.entity';
import { GenePhenotypesService } from '../gene-phenotypes/gene-phenotypes.service';
import { Medication } from '../medications/medication.entity';
import { MedicationsService } from '../medications/medications.service';
import { Guideline, WarningLevel } from './guideline.entity';

@Injectable()
export class GuidelinesService {
    private readonly logger = new Logger(GuidelinesService.name);
    private hashedMedications: Map<string, Medication>;
    private hashedGenePhenotypes: Map<string, Array<Set<GenePhenotype>>>;
    private spreadsheetPhenotypeHeader: Array<Set<string>>;

    constructor(
        private configService: ConfigService,
        @InjectRepository(Guideline)
        private guidelinesRepository: Repository<Guideline>,
        private medicationsService: MedicationsService,
        private genePhenotypesService: GenePhenotypesService,
    ) {
        this.hashedGenePhenotypes = new Map();
        this.hashedMedications = new Map();
        this.spreadsheetPhenotypeHeader = [];
    }

    async fetchGuidelines(): Promise<void> {
        this.clearAllData();

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

        const guidelines: Guideline[] = [];
        for (let row = 0; row < medications.length; row++) {
            const geneSymbolName = genes[row]?.[0];
            const medicationName = medications[row]?.[0];
            if (!geneSymbolName || !medicationName) continue;

            const medication = await this.findMedication(medicationName.value);
            const genePhenotypes = await this.findGenePhenotypes(
                geneSymbolName.value,
            );
            if (genePhenotypes.length === 0 || !medication) continue;

            for (let col = 0; col < implications[row].length; col++) {
                for (const genePhenotype of genePhenotypes[col].values()) {
                    const guideline = new Guideline();
                    const implication = implications[row][col].value?.trim();
                    const recommendation =
                        recommendations[row][col].value?.trim();
                    const warningLevel = this.getWarningLevelFromColor(
                        recommendations[row][col].backgroundColor,
                    );
                    if (
                        !implication ||
                        implication.replace(' ', '').toLowerCase() === 'n/a' ||
                        !recommendation ||
                        recommendation.replace(' ', '').toLowerCase() === 'n/a'
                    ) {
                        continue;
                    }
                    guideline.implication = implication;
                    guideline.recommendation = recommendation;
                    guideline.warningLevel = warningLevel;
                    guideline.genePhenotype = genePhenotype;
                    guideline.medication = medication;
                    guidelines.push(guideline);
                }
            }
        }

        this.guidelinesRepository.save(guidelines);

        this.clearMaps();
    }

    private getWarningLevelFromColor(
        color?: sheets_v4.Schema$Color,
    ): WarningLevel | null {
        if (!color) return null;
        const [red, green, blue] = [color.red, color.green, color.blue];
        if (!red && green === 1 && !blue) return WarningLevel.GREEN;
        if (red === 1 && green === 1 && !blue) return WarningLevel.YELLOW;
        if (red === 1 && !green && !blue) return WarningLevel.RED;
        if (red === green && red === blue && blue === green) return null;
        this.logger.warn('Sheet cell has unknown color');
        return null;
    }

    private async findMedication(name: string): Promise<Medication> {
        if (!name) return null;
        name = name.trim().toLowerCase();
        if (this.hashedMedications.has(name)) {
            return this.hashedMedications.get(name);
        }
        try {
            const medication = await this.medicationsService.getOne({
                where: { name: ILike(name) },
            });

            this.hashedMedications.set(name, medication);
            return medication;
        } catch (error) {
            // TODO: consider proper error handling
            this.logger.error(`Medication ${name} not found in Drugbank data.`);
            this.hashedMedications.set(name, null);
            return null;
        }
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

    async clearAllData(): Promise<void> {
        this.guidelinesRepository.delete({});
        this.clearMaps();
    }

    private clearMaps(): void {
        this.hashedMedications.clear();
        this.hashedGenePhenotypes.clear();
        this.spreadsheetPhenotypeHeader = [];
    }
}
