import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
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

  fetchAnnotations() {
    const url = 'https://s3.pgkb.org/data/clinicalAnnotations.zip';
    const tmpPath = path.join(os.tmpdir(), 'clinical_annotations.zip');
    const unzipTargetPath = path.join(os.tmpdir(), 'clinical_annotations');

    download(url, tmpPath);
    unzip(tmpPath, unzipTargetPath);
  }

  remove(id: number) {
    return this.clinicalAnnotationRepository.delete(id);
  }
}

const download = (url: string, filePath: string) => {
  https.get(url, (res) => {
    const writeStream = fs.createWriteStream(filePath);

    res.pipe(writeStream);

    writeStream.on('finish', () => {
      writeStream.close();
    });
  });
};

const unzip = (zipPath: string, unzipTargetPath: string) => {
  // Create folder if not exists
  if (!fs.existsSync(unzipTargetPath)) {
    fs.mkdirSync(unzipTargetPath);
  }

  // Unzip file
  yauzl.open(zipPath, { lazyEntries: true }, (error, zipfile) => {
    if (error) {
      zipfile.close();
      throw error;
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
            throw error;
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
            throw error;
          });
        });
      }
    });

    zipfile.on('error', (error) => {
      zipfile.close();
      throw error;
    });
  });
};
