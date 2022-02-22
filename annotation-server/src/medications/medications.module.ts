import { Module } from '@nestjs/common';
import { MedicationsController } from './medications.controller';
import { Medication } from './medications.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MedicationsService } from './medications.service';
import { Ingredient } from './ingredients.entity';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [HttpModule, TypeOrmModule.forFeature([Medication, Ingredient])],
  controllers: [MedicationsController],
  providers: [MedicationsService],
})
export class MedicationsModule {}
