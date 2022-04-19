import { IsArray, IsNotEmpty, IsString } from 'class-validator';

import { Phenotype } from '../entities/phenotype.entity';

export class CreateGeneSymbolDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsArray()
    phenotypes: Phenotype[];
}
