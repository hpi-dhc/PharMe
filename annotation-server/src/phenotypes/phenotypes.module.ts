import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { GeneResult } from './entities/gene-result.entity';
import { GeneSymbol } from './entities/gene-symbol.entity';
import { Phenotype } from './entities/phenotype.entity';
import { PhenotypesService } from './phenotypes.service';

@Module({
    imports: [
        HttpModule,
        TypeOrmModule.forFeature([GeneSymbol, GeneResult, Phenotype]),
    ],
    controllers: [],
    providers: [PhenotypesService],
    exports: [PhenotypesService],
})
export class PhenotypesModule {}
