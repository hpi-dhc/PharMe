import { spawn } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import * as JSONStream from 'JSONStream';
import { Repository } from 'typeorm';

import { fetchSpreadsheet } from 'src/common/google-sheets';

import { DrugDto } from './dtos/drugbank.dto';
import { Medication } from './medication.entity';

@Injectable()
export class MedicationsService {
    private readonly logger = new Logger(MedicationsService.name);

    constructor(
        private configService: ConfigService,
        @InjectRepository(Medication)
        private medicationRepository: Repository<Medication>,
    ) {}

    async getAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description', 'synonyms', 'drugclass'],
        });
    }

    async fetchAllMedications(): Promise<void> {
        await this.clearAllMedicationData();
        const jsonPath = await this.getJSONfromZip();
        this.logger.log('Extracting medications from JSON ...');
        const drugs = await this.getDataFromJSON(jsonPath);
        const spreadsheetData = await fetchSpreadsheet(
            this.configService.get<string>('GOOGLESHEET_ID'),
            this.configService.get<string>('GOOGLESHEET_APIKEY'),
            ['HPI List v1!D4:D', 'HPI List v1!A4:A', 'HPI List v1!M4:M'],
        );
        const spreadsheetMedications = new Map<
            string,
            { drugClass?: string; indication?: string }
        >();
        spreadsheetData[0].values.forEach((medicationName, index) => {
            const drugClass = spreadsheetData[1].values[index]?.[0];
            const indication = spreadsheetData[2].values[index]?.[0];
            if (!drugClass && !indication) return;
            spreadsheetMedications.set(medicationName[0].toLowerCase(), {
                drugClass: drugClass,
                indication: indication,
            });
        });
        this.logger.log('Writing to database ...');
        const medications = drugs.map((drug) => {
            const medication = Medication.fromDrug(drug);
            if (spreadsheetMedications.has(medication.name.toLowerCase())) {
                const spreadsheetMedication = spreadsheetMedications.get(
                    medication.name.toLowerCase(),
                );
                medication.drugclass = spreadsheetMedication.drugClass;
                medication.indication = spreadsheetMedication.indication;
            }
            return medication;
        });
        const savedMedications = await this.medicationRepository.save(
            medications,
        );
        this.logger.log(
            `Successfully saved ${savedMedications.length} medications!`,
        );
    }

    async clearAllMedicationData(): Promise<void> {
        await this.medicationRepository.delete({});
    }

    getJSONfromZip(): Promise<string> {
        const jsonPath = path.join(os.tmpdir(), 'drugbank-data.json');
        const proc = spawn(
            path.join(__dirname, './scripts/zipped-xml-to-json'),
            [
                this.configService.get<string>('DRUGBANK_ZIP'),
                this.configService.get<string>('DRUGBANK_XML'),
                jsonPath,
            ],
        );
        proc.on('error', (error) => {
            this.logger.error(error);
        });
        proc.stdout.on('data', (data: string) => {
            this.logger.log(data);
        });
        proc.stderr.on('data', (data: string) => {
            this.logger.error(data);
        });
        return new Promise((resolve, reject) => {
            proc.on('exit', (code) => {
                if (code === 0) resolve(jsonPath);
                else reject(`Subprocess exited with ${code}.`);
            });
        });
    }

    getDataFromJSON(path: string): Promise<DrugDto[]> {
        const jsonStream = fs
            .createReadStream(path)
            .pipe(JSONStream.parse('drugbank.drug.*'));
        const drugs: Array<DrugDto> = [];
        const clearLine = () => {
            process.stdout.write(`\r${String.fromCharCode(27)}[0J`);
        };
        jsonStream.on('data', (drug: DrugDto) => {
            if (!(drugs.length % 50)) {
                clearLine();
                process.stdout.write(`${drugs.length} drugs parsed ...`);
            }
            drugs.push(drug);
        });
        return new Promise<DrugDto[]>((resolve, reject) => {
            jsonStream.on('error', () => {
                clearLine();
                reject();
            });
            jsonStream.on('end', () => {
                clearLine();
                resolve(drugs);
            });
        });
    }
}
