import { Module } from '@nestjs/common';
import { MedicationsController } from './medications.controller';
import { Medication } from './medications.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';
import { MedicationsService } from './medications.service';
import { Ingredient } from './ingredients.entity';
import { RxNormMapping } from './rxnormmappings.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([RxNormMapping, Medication, Ingredient]),
    HttpModule,
  ],
  controllers: [MedicationsController],
  providers: [MedicationsService],
})
export class MedicationsModule {}
