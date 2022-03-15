import * as request from 'supertest'
import { Test } from '@nestjs/testing'
import { INestApplication } from '@nestjs/common'
import { AppModule } from '../src/app.module'

describe('Clinical annotations', () => {
  let app: INestApplication
  jest.setTimeout(300000)

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile()

    app = moduleRef.createNestApplication()
    await app.init()
  })

  it(`/PATCH clinical_annotations/sync`, async () => {
    await request(app.getHttpServer())
      .patch('/clinical_annotations/sync')
      .expect(200)
  })

  it(`should call parseAnnotations and receive clinical annotations`, async () => {
    const response = request(app.getHttpServer()).get('/clinical_annotations')
    response.expect(200)
    expect((await response).body.length).toBeGreaterThan(0)
  })

  it(`should clear the database`, async () => {
    await request(app.getHttpServer())
      .delete('/clinical_annotations')
      .expect(200)
    const response = await request(app.getHttpServer()).get(
      '/clinical_annotations',
    )
    expect(response.body.length).toEqual(0)
  })

  afterAll(async () => {
    await app.close()
  })
})
