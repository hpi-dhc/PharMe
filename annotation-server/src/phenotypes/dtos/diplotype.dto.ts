import { IsNotEmpty, IsString } from 'class-validator';

export class DiplotypeDto {
    @IsString()
    @IsNotEmpty()
    genesymbol: string;

    @IsString()
    @IsNotEmpty()
    generesult: string;

    @IsString()
    @IsNotEmpty()
    consultationtext: string;
}
