import { Module } from '@nestjs/common';

import { S3Service } from './s3.service';
import { MinioModuleConfig } from '../configs/minio.config';

@Module({
    imports: [MinioModuleConfig],
    providers: [S3Service],
    exports: [S3Service],
})
export class S3Module {}
