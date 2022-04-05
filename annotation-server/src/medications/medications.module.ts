import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Medication } from './medication.entity';
import { MedicationsController } from './medications.controller';
import { MedicationsService } from './medications.service';

@Module({
    imports: [HttpModule, TypeOrmModule.forFeature([Medication])],
    controllers: [MedicationsController],
    providers: [MedicationsService],
})
export class MedicationsModule {}
