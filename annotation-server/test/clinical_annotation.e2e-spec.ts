import { INestApplication } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { Test } from '@nestjs/testing'
import { TypeOrmModule } from '@nestjs/typeorm'
import * as request from 'supertest'

import { AnnotationsModule } from '../src/clinical_annotation/clinical_annotation.module'
import { ClinicalAnnotationService } from '../src/clinical_annotation/clinical_annotation.service'

describe('Clinical annotations', () => {
  let app: INestApplication
  let service: ClinicalAnnotationService

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
        }),
        TypeOrmModule.forRootAsync({
          imports: [ConfigModule],
          useFactory: (configService: ConfigService) => ({
            type: 'postgres',
            host: configService.get<string>('ANNOTATION_DB_HOST'),
            port: configService.get<number>('ANNOTATION_DB_PORT'),
            username: configService.get<string>('ANNOTATION_DB_USER'),
            password: configService.get<string>('ANNOTATION_DB_PASS'),
            database: configService.get<string>('ANNOTATION_DB_NAME'),
            autoLoadEntities: true,
            keepConnectionAlive: true,
            synchronize: true,
          }),
          inject: [ConfigService],
        }),
        AnnotationsModule,
      ],
    }).compile()

    app = moduleRef.createNestApplication()

    service = moduleRef.get<ClinicalAnnotationService>(
      ClinicalAnnotationService,
    )
    service.clearData()

    await app.init()
  }, 30000)

  afterAll(async () => {
    await app.close()
  })

  it(`should import, access and delete the database`, async () => {
    await request(app.getHttpServer())
      .patch('/clinical_annotations/sync')
      .expect(200)

    let response = await request(app.getHttpServer())
      .get('/clinical_annotations')
      .expect(200)
    expect((await response).body.length).toBeGreaterThan(0)

    await request(app.getHttpServer())
      .delete('/clinical_annotations')
      .expect(200)
    response = await request(app.getHttpServer()).get('/clinical_annotations')
    expect(response.body.length).toEqual(0)
  })
})
