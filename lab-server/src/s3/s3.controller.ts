import { Controller, Get } from '@nestjs/common';
import { Unprotected } from 'nest-keycloak-connect';
import internal from 'node:stream';

import { S3Service } from './s3.service';

@Controller('s3')
export class S3Controller {
    constructor(private readonly s3Service: S3Service) {}

    @Unprotected()
    @Get()
    async getFile(): Promise<internal.Readable> {
        return await this.s3Service.getFile();
    }
}
