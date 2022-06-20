import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';

import { GuidelinesService } from './guidelines/guidelines.service';
import { MedicationsService } from './medications/medications.service';
import { PhenotypesService } from './phenotypes/phenotypes.service';

@Injectable()
export class AppService {
    constructor(
        private medicationService: MedicationsService,
        private guidelineService: GuidelinesService,
        private phenotypesService: PhenotypesService,
    ) {}

    @Cron('0 0 1 * *', { name: 'monthlyUpdates' })
    async initializeDatabase(): Promise<void> {
        await this.medicationService.fetchAllMedications();
        await this.phenotypesService.fetchPhenotypes();
        await this.guidelineService.fetchGuidelines();
    }
}
