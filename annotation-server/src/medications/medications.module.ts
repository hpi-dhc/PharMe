import { Module } from '@nestjs/common';
import { MedicationsController } from './medications.controller';
import { Medication } from './medications.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';
import { MedicationsService } from './medications.service';

@Module({
  imports: [TypeOrmModule.forFeature([Medication]), HttpModule],
  controllers: [MedicationsController],
  providers: [MedicationsService],
})
export class MedicationsModule {}
