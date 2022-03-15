import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { MedicationsController } from './medications.controller';
import { Medication } from './medications.entity';
import { MedicationsService } from './medications.service';
import { MedicationsGroup } from './medicationsGroup.entity';

@Module({
  imports: [
    HttpModule,
    TypeOrmModule.forFeature([Medication, MedicationsGroup]),
  ],
  controllers: [MedicationsController],
  providers: [MedicationsService],
})
export class MedicationsModule {}
