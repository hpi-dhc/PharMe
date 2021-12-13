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
import * as yauzl from 'yauzl';
import * as fs from 'fs';
import { parse } from 'path/posix';
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
        console.log('clinicalAnnotations deleted');
      }
      await unzip(filePath, { dir: extractedPath });
      console.log('Extraction complete');
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

    StringStream.from(fs.createReadStream(tsvPath))
      // read the file
      .CSVParse({ delimiter: '\t' })
      // parse as csv
      .map((entry) => {
        //console.log(entry[0], entry[6], entry[8], entry[9]);

        if (count > 0) {
          console.log(entry[0], entry[6], entry[8], entry[9]);
          const clinicalAnnotationId = entry[0];
          const variants: string[] = entry[1].split(', ');
          const genes: string = entry[2].split(';');
          const levelOfEvidence: string = entry[3];
          const levelOverride: string = entry[4];
          const levelModifiers: string[] = entry[5].split(';');
          const score = entry[6];
          const phenotypeCategory: string = entry[7];
          const pmidCount = entry[8];
          const evidenceCount = entry[9];
          const drugs: string[] = entry[10].split(';');
          const phenotypes: string[] = entry[11].split(';');
          const latestHistoryDate: Date = new Date(entry[12]);
          const pharmkgbUrl: string = entry[13];
          const specialityPopulation: string = entry[14];

          const clinicalAnnotation = new ClinicalAnnotation();

          clinicalAnnotation.clinicalAnnotationId = clinicalAnnotationId;
          clinicalAnnotation.variants = variants.join(', ');
          clinicalAnnotation.genes = genes;
          clinicalAnnotation.levelOfEvidence = levelOfEvidence;
          clinicalAnnotation.levelOverride = levelOverride;
          clinicalAnnotation.levelModifiers = levelModifiers.join(';');
          clinicalAnnotation.score = score;
          clinicalAnnotation.phenotypeCategory = phenotypeCategory;
          clinicalAnnotation.pmidCount = pmidCount;
          clinicalAnnotation.evidenceCount = evidenceCount;
          clinicalAnnotation.drugs = drugs.join(';');
          clinicalAnnotation.phenotypes = phenotypes.join(';');
          clinicalAnnotation.latestHistoryDate = latestHistoryDate;
          clinicalAnnotation.pharmkgbUrl = pharmkgbUrl;
          clinicalAnnotation.specialityPopulation = specialityPopulation;

          this.clinicalAnnotationRepository.save(clinicalAnnotation);
        }
        count++;
      })
      // whatever you return here it will be changed
      // this can be asynchronous too, so you can do requests...
      .toJSONArray()
      .pipe(createWriteStream(jsonPath));
  }

  async remove(id: string): Promise<void> {
    await this.clinicalAnnotationRepository.delete(id);
  }
}
