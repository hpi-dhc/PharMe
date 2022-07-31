import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

import { InstantiableDto } from '../../common/dtos/instantiable.dto';

export class DiplotypeDto extends InstantiableDto<DiplotypeDto> {
    @IsString()
    @IsNotEmpty()
    genesymbol: string;

    @IsString()
    @IsNotEmpty()
    generesult: string;

    @IsString()
    @IsOptional()
    consultationtext: string;
}
