import { IsArray, IsNotEmpty, IsString } from 'class-validator';

import { GenePhenotype } from '../entities/gene-phenotype.entity';

export class CreateGeneSymbolDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsArray()
    genePhenotypes: GenePhenotype[];
}
