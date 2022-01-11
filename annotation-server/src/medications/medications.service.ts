import { Injectable } from '@nestjs/common';
import { Medication } from './medications.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import * as fs from 'fs';
import * as unzip from 'extract-zip';
import * as path from 'path';
import * as os from 'os';
import { parse } from 'csv-parse';

@Injectable()
export class MedicationsService {
  constructor(
    @InjectRepository(Medication)
    private medicationRepository: Repository<Medication>,
    private httpService: HttpService,
  ) {}

  async fetchMedications() {
    const url =
      'https://dailymed-data.nlm.nih.gov/public-release-files/rxnorm_mappings.zip';
    const tmpPath = path.join(os.tmpdir(), 'medications.zip');
    console.log(tmpPath);
    await this.download(url, tmpPath);
    await this.parseAndSaveData(tmpPath);
  }

  async download(url, filePath): Promise<void> {
    console.log('download');
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

  async parseAndSaveData(filePath): Promise<void> {
    console.log('parseAndSaveData');
    const extractedPath = path.join(os.tmpdir(), 'medications');
    console.log(extractedPath);

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

    const mappingsPath = path.join(
      os.tmpdir(),
      'medications/rxnorm_mappings.txt',
    );

    const medications: Medication[] = [];

    fs.createReadStream(mappingsPath)
      .pipe(parse({ delimiter: '|', from_line: 2 }))
      .on('data', (row) => {
        // it will start from 2nd row
        medications.push(new Medication(row));
      })
      .on('end', async () => {
        //might need to set chunk-option, if errors occur
        console.log('Saving', medications.length, 'medications to database...');
        const savedMedications = await this.medicationRepository
          .save<Medication>(medications, { chunk: 1000 })
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

  async findAll(): Promise<Medication[]> {
    return this.medicationRepository.find();
  }
}
