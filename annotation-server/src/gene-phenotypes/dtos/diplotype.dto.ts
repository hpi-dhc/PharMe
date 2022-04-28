import { IsNotEmpty, IsObject, IsString } from 'class-validator';

export class DiplotypeDto {
    @IsObject()
    lookupkey: { [key: string]: string };

    @IsString()
    @IsNotEmpty()
    generesult: string;
}
