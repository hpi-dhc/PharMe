import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createWriteStream } from 'fs';
import * as path from 'path';
import { Repository } from 'typeorm';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import * as os from 'os';
import * as http from 'http';
import * as https from 'https';
import * as fs from 'fs';
import * as unzip from 'extract-zip';
import { StringStream } from 'scramjet';

@Injectable()
export class ClinicalAnnotationService {
  constructor(
    @InjectRepository(ClinicalAnnotation)
    private clinicalAnnotationRepository: Repository<ClinicalAnnotation>,
    private httpService: HttpService,
  ) {}

  async findAll(): Promise<ClinicalAnnotation[]> {
    return await this.clinicalAnnotationRepository.find();
  }

  synchronize() {
    const url = 'https://s3.pgkb.org/data/clinicalAnnotations.zip';
    const tmpPath = path.join(os.tmpdir(), 'clinical_annotations.zip');
    this.download(url, tmpPath);
  }

  async download(url, filePath) {
    const proto = !url.charAt(4).localeCompare('s') ? https : http;
    return new Promise((resolve, reject) => {
      const file = fs.createWriteStream(filePath);
      let fileInfo = null;

      const request = proto.get(url, (response) => {
        if (response.statusCode !== 200) {
          reject(new Error(`Failed to get '${url}' (${response.statusCode})`));
          return;
        }
        fileInfo = {
          mime: response.headers['content-type'],
          size: parseInt(response.headers['content-length'], 10),
        };

        response.pipe(file);
      });

      file.on('finish', () => {
        resolve(fileInfo);
        this.parseData(filePath);
      });

      request.on('error', (err) => {
        fs.unlink(filePath, () => reject(err));
      });

      file.on('error', (err) => {
        fs.unlink(filePath, () => reject(err));
      });

      request.end();
    });
  }

  async parseData(filePath) {
    const extractedPath = path.join(os.tmpdir(), 'clinicalAnnotations');

    try {
      if (fs.existsSync(extractedPath)) {
        fs.rmdirSync(extractedPath, { recursive: true });
      }
      await unzip(filePath, { dir: extractedPath });
    } catch (err) {
      // handle any errors
      console.log(err);
    }

    const tsvPath = path.join(
      os.tmpdir(),
      'clinicalAnnotations/clinical_annotations.tsv',
    );

    const annotations: ClinicalAnnotation[] = [];

    await StringStream.from(fs.createReadStream(tsvPath))
      .CSVParse({ delimiter: '\t' })
      .slice(1)
      .map((entry) => annotations.push(new ClinicalAnnotation(entry)))
      .whenEnd();

    await this.clinicalAnnotationRepository.save<ClinicalAnnotation>(
      annotations,
      { chunk: 5000 },
    );
  }

  async remove(id: string): Promise<void> {
    await this.clinicalAnnotationRepository.delete(id);
  }
}
