import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { FetchDatesModule } from '../fetch-dates/fetch-dates.module';
import { Medication, MedicationSearchView } from './medication.entity';
import { MedicationsController } from './medications.controller';
import { MedicationsService } from './medications.service';

@Module({
    imports: [
        HttpModule,
        TypeOrmModule.forFeature([Medication, MedicationSearchView]),
        FetchDatesModule,
    ],
    controllers: [MedicationsController],
    providers: [MedicationsService],
    exports: [MedicationsService],
})
export class MedicationsModule {}
