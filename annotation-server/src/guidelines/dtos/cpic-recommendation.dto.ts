import { IsNotEmpty, IsNumber, IsObject, IsString } from 'class-validator';

export class CpicRecommendationDto {
    @IsString()
    @IsNotEmpty()
    drugid: string;

    @IsString()
    drugrecommendation: string;

    @IsObject()
    implications: { [key: string]: string };

    @IsString()
    comments: string;

    @IsObject()
    phenotypes: { [key: string]: string };

    @IsString()
    classification: string;

    @IsNumber()
    guidelineid: number;
}
