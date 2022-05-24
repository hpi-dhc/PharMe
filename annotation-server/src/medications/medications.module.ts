import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Medication, MedicationSearchView } from './medication.entity';
import { MedicationsController } from './medications.controller';
import { MedicationsService } from './medications.service';

@Module({
    imports: [
        HttpModule,
        TypeOrmModule.forFeature([Medication, MedicationSearchView]),
    ],
    controllers: [MedicationsController],
    providers: [MedicationsService],
    exports: [MedicationsService],
})
export class MedicationsModule {}
