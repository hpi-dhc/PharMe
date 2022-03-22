import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DOMParser } from 'xmldom';
import * as xpath from 'xpath';

import { unzip } from '../common/utils/download-unzip';
import { Medication } from './medications.entity';

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
        const drugbankDoc = await this.getDataFromZip();
        const select = xpath.useNamespaces({ n: 'http://www.drugbank.ca' });
        const drugs = select('/n:drugbank/n:drug', drugbankDoc);
    }

    async getDataFromZip(): Promise<Document> {
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
        const domParser = new DOMParser();
        return domParser.parseFromString(xmlContent.toString());
    }

    async getAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description'],
        });
    }
}
