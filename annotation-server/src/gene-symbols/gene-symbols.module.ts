import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { GeneSymbol } from './entities/gene-symbol.entity';
import { Phenotype } from './entities/phenotype.entity';
import { GeneSymbolsController } from './gene-symbols.controller';
import { GeneSymbolsService } from './gene-symbols.service';

@Module({
    imports: [HttpModule, TypeOrmModule.forFeature([GeneSymbol, Phenotype])],
    controllers: [GeneSymbolsController],
    providers: [GeneSymbolsService],
})
export class GeneSymbolsModule {}
