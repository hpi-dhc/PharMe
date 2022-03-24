import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { XMLParser } from 'fast-xml-parser';
import { Repository } from 'typeorm';

import { unzip } from '../common/utils/download-unzip';
import { Drugbank, Medication } from './medication.entity';

@Injectable()
export class MedicationsService {
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
        const drugbank = await this.getDataFromZip();
        const medications = drugbank.drugbank.drug.map((drug) =>
            Medication.fromDrug(drug),
        );
        this.medicationRepository.save(medications);
    }

    async getDataFromZip(): Promise<Drugbank> {
        const unzipPath = path.join(os.tmpdir(), 'drugbank_data');
        await unzip(
            path.join(
                __dirname,
                this.configService.get<string>('DRUGBANK_ZIP'),
            ),
            unzipPath,
        );
        const xmlContent = fs.readFileSync(
            path.join(
                unzipPath,
                this.configService.get<string>('DRUGBANK_XML'),
            ),
        );
        const parser = new XMLParser({ removeNSPrefix: true });
        return parser.parse(xmlContent);
    }

    async getAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description', 'synonyms'],
        });
    }
}
