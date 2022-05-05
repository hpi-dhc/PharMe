import { Injectable } from '@nestjs/common';

import { GenePhenotypesService } from './gene-phenotypes/gene-phenotypes.service';
import { GuidelinesService } from './guidelines/guidelines.service';
import { MedicationsService } from './medications/medications.service';

@Injectable()
export class AppService {
    constructor(
        private medicationService: MedicationsService,
        private guidelineService: GuidelinesService,
        private genephenotypeService: GenePhenotypesService,
    ) {}

    async initializeDatabase(): Promise<void> {
        await this.medicationService.fetchAllMedications();
        await this.genephenotypeService.fetchGenePhenotypes();
        await this.guidelineService.fetchGuidelines();
    }
}
