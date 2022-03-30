import { Injectable } from '@nestjs/common';
import { MinioService } from 'nestjs-minio-client';
import internal from 'node:stream';

@Injectable()
export class S3Service {
    constructor(private readonly minioClient: MinioService) {}

    async getFile(): Promise<internal.Readable> {
        return await this.minioClient.client.getObject(
            'alleles',
            '204753010001_R01C01.json',
        );
    }
}
