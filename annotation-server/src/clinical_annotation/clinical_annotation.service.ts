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

  async findAll(): Promise<ListableAnnotation[]> {
    // get full clinical annotations and deprecate them to a less bloated format
    // --> ListAllClinicalAnnotations
    const fullAnnotations = await this.clinicalAnnotationRepository.find();

    const deprecatedAnnotations: ListableAnnotation[] = [];
    for (const annotation of fullAnnotations) {
      deprecatedAnnotations.push({
        clinicalAnnotationId: annotation.clinicalAnnotationId,
        variants: annotation.variants,
        genes: annotation.genes,
        levelOfEvidence: annotation.levelOfEvidence,
        score: annotation.score,
        phenotypeCategory: annotation.phenotypeCategory,
        drugs: annotation.drugs,
        phenotypes: annotation.phenotypes,
        pharmkgbUrl: annotation.pharmkgbUrl,
      });
    }

    return deprecatedAnnotations;
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

    // TODO: add extract-zip to npm requirements

    try {
      if (fs.existsSync(extractedPath)) {
        fs.rmdirSync(extractedPath, { recursive: true });
      }
      await unzip(filePath, { dir: extractedPath });
    } catch (err) {
      // handle any errors
      console.log(err);
    }

    const jsonPath = path.join(os.tmpdir(), 'clinicalAnnotations.json');
    const tsvPath = path.join(
      os.tmpdir(),
      'clinicalAnnotations/clinical_annotations.tsv',
    );

    let count = 0;

    // todo add scramjet to npm requirements
    const annotations: ClinicalAnnotation[] = [];

    StringStream.from(fs.createReadStream(tsvPath))
      // read the file
      .CSVParse({ delimiter: '\t' })
      // parse as csv
      .map((entry) => {
        if (count > 0) {
          const temp = new ClinicalAnnotation();
          temp.clinicalAnnotationId = entry[0];
          temp.variants = entry[1].split(', ');
          temp.genes = entry[2].split(';');
          temp.levelOfEvidence = entry[3];
          temp.levelOverride = entry[4];
          temp.levelModifiers = entry[5].split(';');
          temp.score = entry[6];
          temp.phenotypeCategory = entry[7];
          temp.pmidCount = entry[8];
          temp.evidenceCount = entry[9];
          temp.drugs = entry[10].split(';');
          temp.phenotypes = entry[11].split(';');
          temp.latestHistoryDate = new Date(entry[12]);
          temp.pharmkgbUrl = entry[13];
          temp.specialityPopulation = entry[14];

          annotations.push(temp);
        }
        count++;
      })
      // whatever you return here it will be changed
      // this can be asynchronous too, so you can do requests...
      .toJSONArray()
      .pipe(createWriteStream(jsonPath));

    await this.clinicalAnnotationRepository.save(annotations);
  }

  async remove(id: string): Promise<void> {
    await this.clinicalAnnotationRepository.delete(id);
  }
}
