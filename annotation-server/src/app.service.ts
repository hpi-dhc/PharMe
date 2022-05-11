import { Injectable } from '@nestjs/common';
import { Cron, SchedulerRegistry } from '@nestjs/schedule';

import { GenePhenotypesService } from './gene-phenotypes/gene-phenotypes.service';
import { GuidelinesService } from './guidelines/guidelines.service';
import { MedicationsService } from './medications/medications.service';

@Injectable()
export class AppService {
    constructor(
        private schedulerRegistry: SchedulerRegistry,
        private medicationService: MedicationsService,
        private guidelineService: GuidelinesService,
        private genephenotypeService: GenePhenotypesService,
    ) {}

    @Cron('0 0 1 * *', { name: 'monthlyUpdates' })
    async initializeDatabase(): Promise<void> {
        await this.medicationService.fetchAllMedications();
        await this.genephenotypeService.fetchGenePhenotypes();
        await this.guidelineService.fetchGuidelines();
    }
}
