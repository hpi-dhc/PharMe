import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DOMParser } from 'xmldom';
import * as xpath from 'xpath';

import { Medication } from './medications.entity';

@Injectable()
export class MedicationsService {
    constructor(
        @InjectRepository(Medication)
        private medicationRepository: Repository<Medication>,
        private httpService: HttpService,
    ) {}

    async clearAllMedicationData(): Promise<void> {
        await this.medicationRepository.delete({});
    }

    async fetchAllMedications(): Promise<void> {
        await this.clearAllMedicationData();
    }

    async getAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description'],
        });
    }
}
