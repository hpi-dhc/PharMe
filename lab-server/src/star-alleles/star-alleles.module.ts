import { Module } from '@nestjs/common';
import { StarAllelesController } from './star-alleles.controller';
import { StarAllelesService } from './star-alleles.service';

@Module({
  controllers: [StarAllelesController],
  providers: [StarAllelesService],
})
export class StarAllelesModule {}
