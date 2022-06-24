import { Injectable } from '@nestjs/common';

import { GuidelinesService } from './guidelines/guidelines.service';
import { MedicationsService } from './medications/medications.service';

@Injectable()
export class AppService {
    constructor(
        private medicationService: MedicationsService,
        private guidelineService: GuidelinesService,
    ) {}

    async initializeDatabase(): Promise<void> {
        await this.medicationService.fetchAllMedications();
        await this.guidelineService.fetchGuidelines();
    }
}
