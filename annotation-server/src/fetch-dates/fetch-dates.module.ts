import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { FetchDate } from './fetch-date.entity';
import { FetchDatesService } from './fetch-dates.service';

@Module({
    imports: [TypeOrmModule.forFeature([FetchDate])],
    providers: [FetchDatesService],
    exports: [FetchDatesService],
})
export class FetchDatesModule {}
