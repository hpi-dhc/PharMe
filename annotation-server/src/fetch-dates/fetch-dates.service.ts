import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { FetchDate, FetchTarget } from './fetch-date.entity';

@Injectable()
export class FetchDatesService {
    constructor(
        @InjectRepository(FetchDate)
        private fetchDatesRepository: Repository<FetchDate>,
    ) {}

    async get(target: FetchTarget): Promise<Date | undefined> {
        const fetchDate = await this.fetchDatesRepository.findOneBy({ target });
        return fetchDate?.date;
    }

    async set(target: FetchTarget): Promise<void> {
        try {
            await this.fetchDatesRepository.insert({ target });
        } catch {
            await this.fetchDatesRepository.update({ target }, { target });
        }
    }
}
