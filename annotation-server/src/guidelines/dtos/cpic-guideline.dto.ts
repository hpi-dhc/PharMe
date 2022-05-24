import { IsNotEmpty, IsNumber, IsString, IsUrl } from 'class-validator';

export class CpicGuidelineDto {
    @IsNumber()
    @IsNotEmpty()
    id: number;

    @IsString()
    @IsNotEmpty()
    name: string;

    @IsUrl()
    @IsNotEmpty()
    url: string;
}
