import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { parse } from 'csv-parse';
import * as fs from 'fs';
import * as https from 'https';
import * as os from 'os';
import * as path from 'path';
import { Repository } from 'typeorm';
import * as yauzl from 'yauzl';
import { ClinicalAnnotation } from './clinical_annotation.entity';

@Injectable()
export class ClinicalAnnotationService {
  constructor(
    @InjectRepository(ClinicalAnnotation)
    private readonly clinicalAnnotationRepository: Repository<ClinicalAnnotation>,
  ) {}

  findAll() {
    this.clinicalAnnotationRepository.find();
  }

  async syncAnnotations() {
    const url = 'https://s3.pgkb.org/data/clinicalAnnotations.zip';
    const zipPath = path.join(os.tmpdir(), 'clinical_annotations.zip');
    const unzipTargetPath = path.join(os.tmpdir(), 'clinical_annotations');
    const annotationsTsvPath = path.join(
      unzipTargetPath,
      'clinical_annotations.tsv',
    );

    await download(url, zipPath);
    await unzip(zipPath, unzipTargetPath);
    const annotations = await parseAnnotations(annotationsTsvPath);

    // Persist annotations in array
    await this.clinicalAnnotationRepository.save(annotations, {
      chunk: 500,
    });
  }

  remove(id: number) {
    return this.clinicalAnnotationRepository.delete(id);
  }
}

const download = (url: string, filePath: string) => {
  return new Promise<void>((resolve) => {
    https.get(url, (res) => {
      const writeStream = fs.createWriteStream(filePath);

      res.pipe(writeStream);

      writeStream.on('finish', () => {
        writeStream.close();
        resolve();
      });
    });
  });
};

const unzip = (zipPath: string, unzipTargetPath: string) => {
  return new Promise<void>((resolve, reject) => {
    try {
      // Create folder if not exists
      if (!fs.existsSync(unzipTargetPath)) {
        fs.mkdirSync(unzipTargetPath);
      }

      // Unzip file
      yauzl.open(zipPath, { lazyEntries: true }, (error, zipfile) => {
        if (error) {
          zipfile.close();
          reject(error);
          return;
        }

        // Read first entry
        zipfile.readEntry();

        // Trigger next cycle, every time we read an entry
        zipfile.on('entry', (entry) => {
          // Directories
          if (/\/$/.test(entry.fileName)) {
            // If it is a directory, it needs to be created
            const dirPath = path.join(unzipTargetPath, entry.fileName);
            if (!fs.existsSync(dirPath)) {
              fs.mkdirSync(dirPath);
            }
            zipfile.readEntry();
          }
          // Files
          else {
            zipfile.openReadStream(entry, (error, readStream) => {
              if (error) {
                zipfile.close();
                reject(error);
                return;
              }

              const filePath = path.join(unzipTargetPath, entry.fileName);
              const file = fs.createWriteStream(filePath);
              readStream.pipe(file);

              file.on('finish', () => {
                // Wait until the file is finished writing, then read the next entry.
                file.close(() => {
                  zipfile.readEntry();
                });
              });

              file.on('error', (error) => {
                zipfile.close();
                reject(error);
              });
            });
          }
        });

        zipfile.on('end', () => {
          resolve();
        });

        zipfile.on('error', (error) => {
          zipfile.close();
          reject(error);
        });
      });
    } catch (error) {
      reject(error);
    }
  });
};

const parseAnnotations = (filePath: string) => {
  return new Promise<ClinicalAnnotation[]>((resolve, reject) => {
    const annotations: ClinicalAnnotation[] = [];

    const readStream = fs.createReadStream(filePath);
    readStream
      .pipe(parse({ delimiter: '\t', fromLine: 2 }))
      .on('data', (row) => {
        const annotation = new ClinicalAnnotation();

        // Clinical Annotation ID needs to be present
        if (!row[0]) {
          readStream.close();
          reject('Clinical Annotation ID needs to be present');
        }

        annotation.clinicalAnnotationId = Number(row[0]);
        annotation.variants = row[1] ? String(row[1]) : null;
        annotation.genes = row[2] ? String(row[2]) : null;
        annotation.levelOfEvidence = row[3] ? String(row[3]) : null;
        annotation.levelOverride = row[4] ? String(row[4]) : null;
        annotation.levelModifiers = row[5] ? String(row[5]) : null;
        annotation.score = row[6] ? Number(row[6]) : null;
        annotation.phenotypeCategory = row[7] ? String(row[7]) : null;
        annotation.pmidCount = row[8] ? Number(row[8]) : null;
        annotation.evidenceCount = row[9] ? Number(row[9]) : null;
        annotation.drugs = row[10] ? String(row[10]) : null;
        annotation.phenotypes = row[11] ? String(row[11]) : null;
        annotation.latestHistoryDate = row[12] ? new Date(row[12]) : null;
        annotation.pharmkgbUrl = row[13] ? String(row[13]) : null;
        annotation.specialityPopulation = row[14] ? String(row[14]) : null;

        annotations.push(annotation);
      })
      .on('end', () => {
        resolve(annotations);
      });
  });
};
