import { Injectable } from '@nestjs/common';
import { RxNormMapping } from './rxnormmappings.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';
import { parse } from 'csv-parse';
import { downloadAndUnzip } from '../common/utils/download-unzip';

@Injectable()
export class RxNormMappingsService {
  constructor(
    @InjectRepository(RxNormMapping)
    private rxNormMappingRepository: Repository<RxNormMapping>
  ) {}

  async fetchMedications() {
    const url =
      'https://dailymed-data.nlm.nih.gov/public-release-files/rxnorm_mappings.zip';
    const tmpPath = path.join(os.tmpdir(), 'medications');
    await downloadAndUnzip(url, tmpPath);
    await this.parseAndSaveData();
  }

  async parseAndSaveData(): Promise<void> {
    const mappingsPath = path.join(
      os.tmpdir(),
      'medications/rxnorm_mappings.txt',
    );

    const rxNormMappings: RxNormMapping[] = [];
    const setids = new Set();
    const rxstrings = new Set();

    fs.createReadStream(mappingsPath)
      .pipe(parse({ delimiter: '|', from_line: 2 }))
      .on('data', (row) => {
        // it will start from 2nd row
        if (!setids.has(row[0]) || !rxstrings.has(row[3])) {
          rxNormMappings.push(new RxNormMapping(row));
          setids.add(row[0]);
          rxstrings.add(row[3]);
        }
      })
      .on('end', async () => {
        // might need to set chunk-option, if errors occur
        console.log(
          'Saving',
          rxNormMappings.length,
          'medications to database...',
        );
        const savedMedications = await this.rxNormMappingRepository
          .save<RxNormMapping>(rxNormMappings, { chunk: 1000 })
          .catch((error) => {
            console.error(error);
          });

        if (savedMedications) {
          console.log(
            'Successfully saved',
            savedMedications.length,
            'to database!',
          );
        } else {
          console.error('Error saving medications!');
        }
      });
  }

  async findAll(query?: string): Promise<RxNormMapping[]> {
    if (query) {
      // TODO: Case insensitive
      return this.rxNormMappingRepository.find({
        rxstring: Like("%" + query + "%")
      });
    } else {
      return this.rxNormMappingRepository.find({ take: 100 });
    }
  }
}