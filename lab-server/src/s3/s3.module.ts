import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { MinioModuleConfig } from 'src/configs/minio.config';

import { S3Controller } from './s3.controller';
import { S3Service } from './s3.service';

@Module({
    imports: [ConfigModule, MinioModuleConfig],
    controllers: [S3Controller],
    providers: [S3Service],
})
export class S3Module {}
