import { spawn } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import * as JSONStream from 'JSONStream';
import { Repository } from 'typeorm';

import { Drug } from './interfaces/drugbank.interface';
import { Medication } from './medication.entity';

@Injectable()
export class MedicationsService {
    private readonly logger = new Logger(MedicationsService.name);

    constructor(
        private configService: ConfigService,
        @InjectRepository(Medication)
        private medicationRepository: Repository<Medication>,
    ) {}

    async clearAllMedicationData(): Promise<void> {
        await this.medicationRepository.delete({});
    }

    async fetchAllMedications(): Promise<void> {
        await this.clearAllMedicationData();
        const jsonPath = await this.getJSONfromZip();
        this.logger.log('Extracting medications from JSON ...');
        const drugs = await this.getDataFromJSON(jsonPath);
        this.logger.log('Writing to database ...');
        const medications = drugs.map((drug) => Medication.fromDrug(drug));
        const savedMedications = await this.medicationRepository.save(
            medications,
        );
        this.logger.log(
            `Successfully saved ${savedMedications.length} medications!`,
        );
    }

    getJSONfromZip(): Promise<string> {
        const jsonPath = path.join(os.tmpdir(), 'drugbank-data.json');
        const proc = spawn(
            path.join(__dirname, '../common/scripts/zipped-xml-to-json'),
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

    getDataFromJSON(path: string): Promise<Drug[]> {
        const jsonStream = fs
            .createReadStream(path)
            .pipe(JSONStream.parse('drugbank.drug.*'));
        const drugs: Array<Drug> = [];
        const clearLine = () => {
            process.stdout.write(`\r${String.fromCharCode(27)}[0J`);
        };
        jsonStream.on('data', (drug: Drug) => {
            if (!(drugs.length % 50)) {
                clearLine();
                process.stdout.write(`${drugs.length} drugs parsed ...`);
            }
            drugs.push(drug);
        });
        return new Promise<Drug[]>((resolve, reject) => {
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

    async getAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description', 'synonyms'],
        });
    }
}
