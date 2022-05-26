import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { GenePhenotype } from './entities/gene-phenotype.entity';
import { GeneSymbol } from './entities/gene-symbol.entity';
import { Phenotype } from './entities/phenotype.entity';
import { GenePhenotypesService } from './gene-phenotypes.service';

@Module({
    imports: [
        HttpModule,
        TypeOrmModule.forFeature([GeneSymbol, Phenotype, GenePhenotype]),
    ],
    controllers: [],
    providers: [GenePhenotypesService],
    exports: [GenePhenotypesService],
})
export class GenePhenotypesModule {}
