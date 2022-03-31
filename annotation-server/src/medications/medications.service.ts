import * as fs from 'fs';

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import * as JSONStream from 'JSONStream';
import { Repository } from 'typeorm';

import { Drug, Medication } from './medication.entity';

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
        const drugs = await this.getDataFromJSON();
        console.log();
        const medications = drugs.map((drug) => Medication.fromDrug(drug));
        const savedMedications = await this.medicationRepository.save(
            medications,
        );
        this.logger.log(
            `Successfully saved ${savedMedications.length} medications!`,
        );
    }

    getDataFromJSON(): Promise<Drug[]> {
        const jsonStream = fs
            .createReadStream('src/medications/full-database.json')
            .pipe(JSONStream.parse('drugbank.drug.*'));
        const drugs: Array<Drug> = [];
        jsonStream.on('data', (drug: Drug) => {
            if (!(drugs.length % 20)) {
                process.stdout.write(
                    `\r${String.fromCharCode(27)}[0J${drugs.length}`,
                );
            }
            drugs.push(drug);
        });
        return new Promise<Drug[]>((resolve, reject) => {
            jsonStream.on('error', () => reject);
            jsonStream.on('end', () => resolve(drugs));
        });
    }

    async getAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description', 'synonyms'],
        });
    }
}
