import internal from 'stream';

import { HttpException, Injectable } from '@nestjs/common';
import { MinioService } from 'nestjs-minio-client';

@Injectable()
export class S3Service {
    constructor(private readonly minioClient: MinioService) {}

    private streamToString(stream: internal.Readable): Promise<string> {
        const chunks = [];
        return new Promise((resolve, reject) => {
            stream.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
            stream.on('error', (err) => reject(err));
            stream.on('end', () =>
                resolve(Buffer.concat(chunks).toString('utf8')),
            );
        });
    }

    async getFile(): Promise<string> {
        try {
            const stream = await this.minioClient.client.getObject(
                'alleles',
                '204753010001_R04C01.json',
            );
            return this.streamToString(stream);
        } catch (error) {
            throw new HttpException('Could not find file', 400);
        }
    }
}
