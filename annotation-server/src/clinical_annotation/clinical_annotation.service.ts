import * as fs from 'fs'
import * as os from 'os'
import * as path from 'path'

import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { parse } from 'csv-parse'
import { Repository } from 'typeorm'

import { downloadAndUnzip } from '../common/utils/download-unzip'
import { ClinicalAnnotation } from './clinical_annotation.entity'

@Injectable()
export class ClinicalAnnotationService {
  constructor(
    @InjectRepository(ClinicalAnnotation)
    private readonly clinicalAnnotationRepository: Repository<ClinicalAnnotation>,
  ) {}

  async syncAnnotations(): Promise<void> {
    const url = 'https://s3.pgkb.org/data/clinicalAnnotations.zip'
    const unzipTargetPath = path.join(os.tmpdir(), 'clinical_annotations')
    const annotationsTsvPath = path.join(
      unzipTargetPath,
      'clinical_annotations.tsv',
    )

    await downloadAndUnzip(url, unzipTargetPath)
    const annotations = await this.parseAnnotations(annotationsTsvPath)

    // Persist annotations in array
    await this.clinicalAnnotationRepository.save(annotations, {
      chunk: 500,
    })
  }

  async parseAnnotations(filePath: string) {
    return new Promise<ClinicalAnnotation[]>((resolve, reject) => {
      const annotations: ClinicalAnnotation[] = []

      const readStream = fs.createReadStream(filePath)
      readStream
        .pipe(parse({ delimiter: '\t', fromLine: 2 }))
        .on('data', (row) => {
          const annotation = new ClinicalAnnotation()

          // Clinical Annotation ID needs to be present
          if (!row[0]) {
            readStream.close()
            reject('Clinical Annotation ID needs to be present')
          }

          annotation.clinicalAnnotationId = Number(row[0])
          annotation.variants = row[1] ? String(row[1]) : null
          annotation.genes = row[2] ? String(row[2]) : null
          annotation.levelOfEvidence = row[3] ? String(row[3]) : null
          annotation.levelOverride = row[4] ? String(row[4]) : null
          annotation.levelModifiers = row[5] ? String(row[5]) : null
          annotation.score = row[6] ? Number(row[6]) : null
          annotation.phenotypeCategory = row[7] ? String(row[7]) : null
          annotation.pmidCount = row[8] ? Number(row[8]) : null
          annotation.evidenceCount = row[9] ? Number(row[9]) : null
          annotation.drugs = row[10] ? String(row[10]) : null
          annotation.phenotypes = row[11] ? String(row[11]) : null
          annotation.latestHistoryDate = row[12] ? new Date(row[12]) : null
          annotation.pharmkgbUrl = row[13] ? String(row[13]) : null
          annotation.specialityPopulation = row[14] ? String(row[14]) : null

          annotations.push(annotation)
        })
        .on('end', () => {
          resolve(annotations)
        })
    })
  }

  async getAll(): Promise<ClinicalAnnotation[]> {
    return this.clinicalAnnotationRepository.find()
  }

  async clearData(): Promise<void> {
    await this.clinicalAnnotationRepository.delete({});
  }
}
