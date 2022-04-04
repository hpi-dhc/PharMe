import { Module } from '@nestjs/common';

import { MinioModuleConfig } from '../configs/minio.config';
import { S3Service } from './s3.service';

@Module({
    imports: [MinioModuleConfig],
    providers: [S3Service],
    exports: [S3Service],
})
export class S3Module {}
