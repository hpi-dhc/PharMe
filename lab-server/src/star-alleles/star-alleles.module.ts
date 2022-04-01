import { Module } from '@nestjs/common';

import { UsersModule } from 'src/user/user.module';

import { S3Module } from '../s3/s3.module';
import { StarAllelesController } from './star-alleles.controller';
import { StarAllelesService } from './star-alleles.service';

@Module({
    controllers: [StarAllelesController],
    imports: [UsersModule, S3Module],
    providers: [StarAllelesService],
})
export class StarAllelesModule {}
