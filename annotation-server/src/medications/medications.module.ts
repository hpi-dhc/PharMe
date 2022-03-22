import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { MedicationsController } from './medications.controller';
import { Medication } from './medications.entity';
import { MedicationsService } from './medications.service';

@Module({
    imports: [HttpModule, TypeOrmModule.forFeature([Medication])],
    controllers: [MedicationsController],
    providers: [MedicationsService],
})
export class MedicationsModule {}
