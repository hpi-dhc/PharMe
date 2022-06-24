import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { FetchDatesModule } from '../fetch-dates/fetch-dates.module';
import { MedicationsModule } from '../medications/medications.module';
import { PhenotypesModule } from '../phenotypes/phenotypes.module';
import { GuidelineError } from './entities/guideline-error.entity';
import { Guideline } from './entities/guideline.entity';
import { GuidelinesController } from './guidelines.controller';
import { GuidelinesService } from './guidelines.service';

@Module({
    imports: [
        HttpModule,
        PhenotypesModule,
        MedicationsModule,
        TypeOrmModule.forFeature([Guideline, GuidelineError]),
        FetchDatesModule,
    ],
    controllers: [GuidelinesController],
    providers: [GuidelinesService],
    exports: [GuidelinesService],
})
export class GuidelinesModule {}
