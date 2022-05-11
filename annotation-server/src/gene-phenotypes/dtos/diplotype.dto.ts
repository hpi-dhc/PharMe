import { IsNotEmpty, IsObject, IsString } from 'class-validator';

export class DiplotypeDto {
    @IsString()
    @IsNotEmpty()
    genesymbol: string;

    @IsString()
    @IsNotEmpty()
    generesult: string;
}
