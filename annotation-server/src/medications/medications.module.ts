import { Module } from '@nestjs/common';
import { MedicationsController } from './medications.controller';
import { Medication } from './medications.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MedicationsService } from './medications.service';
import { HttpModule } from '@nestjs/axios';
import { MedicationsGroup } from './medicationsGroup.entity';

@Module({
  imports: [HttpModule, TypeOrmModule.forFeature([Medication, MedicationsGroup])],
  controllers: [MedicationsController],
  providers: [MedicationsService],
})
export class MedicationsModule {}
