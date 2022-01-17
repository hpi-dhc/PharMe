import { Injectable } from '@nestjs/common';
import { Medication } from './medications.entity';
import { RxNormMapping } from './rxnormmappings.entity';
import { Ingredient } from './ingredients.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import * as fs from 'fs';
import * as unzip from 'extract-zip';
import * as path from 'path';
import * as os from 'os';
import { parse } from 'csv-parse';
import { parseString } from 'xml2js';

@Injectable()
export class MedicationsService {
  constructor(
    @InjectRepository(RxNormMapping)
    private rxNormMappingRepository: Repository<RxNormMapping>,
    @InjectRepository(Medication)
    private medicationRepository: Repository<Medication>,
    @InjectRepository(Ingredient)
    private ingredientRepository: Repository<Ingredient>,
    private httpService: HttpService,
  ) {}

  async fetchMedications() {
    const url =
      'https://dailymed-data.nlm.nih.gov/public-release-files/rxnorm_mappings.zip';
    const tmpPath = path.join(os.tmpdir(), 'medications.zip');
    await this.download(url, tmpPath);
    await this.unzipToDirectory(tmpPath, 'medications');
    await this.parseAndSaveData();
  }

  async download(url, filePath): Promise<void> {
    const file = fs.createWriteStream(filePath);
    try {
      const response = await lastValueFrom(
        this.httpService.get(url, {
          headers: {
            Accept: 'application/zip',
          },
          responseType: 'arraybuffer',
        }),
      );
      file.write(response.data);
    } catch (err) {
      console.log(err);
    }
  }

  async unzipToDirectory(filePath: string, dirName: string): Promise<void> {
    const extractedPath = path.join(os.tmpdir(), dirName);

    try {
      if (fs.existsSync(extractedPath)) {
        fs.rm(extractedPath, { recursive: true }, (err) => {
          if (err) {
            console.log(err);
          }
        });
      }
      await unzip(filePath, { dir: extractedPath });
    } catch (err) {
      // handle any errors
      console.log(err);
    }
  }

  async parseAndSaveData(): Promise<void> {
    const mappingsPath = path.join(
      os.tmpdir(),
      'medications/rxnorm_mappings.txt',
    );

    const rxNormMappings: RxNormMapping[] = [];

    fs.createReadStream(mappingsPath)
      .pipe(parse({ delimiter: '|', from_line: 2 }))
      .on('data', (row) => {
        // it will start from 2nd row
        rxNormMappings.push(new RxNormMapping(row));
      })
      .on('end', async () => {
        //might need to set chunk-option, if errors occur
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

  async findAll(): Promise<RxNormMapping[]> {
    return this.rxNormMappingRepository.find();
  }

  async findOne(id: string): Promise<Medication> {
    const mappings = await this.rxNormMappingRepository.find({ 
      where: {
        setid: id,
      },
     });

    if (!mappings.length) {
      return null;
    }

    if (mappings[0].medication) {
      return mappings[0].medication;
    }

    const tmpPath = path.join(os.tmpdir(), id + '.zip');

    const url =
      'https://dailymed.nlm.nih.gov/dailymed/getFile.cfm?setid=' +
      id +
      '&type=zip';

    await this.download(url, tmpPath);

    await this.unzipToDirectory(tmpPath, id);

    const xmlPath = path.join(os.tmpdir(), id + '/' + id + '.xml');

    fs.readFile(xmlPath, (err, data) => {
      parseString(data, (err, result) => {
        console.dir(result);
      });
    });

    return null;
  }
}
