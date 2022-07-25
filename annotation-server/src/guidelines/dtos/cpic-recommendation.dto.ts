import { IsNotEmpty, IsNumber, IsObject, IsString } from 'class-validator';

import { InstantiableDto } from '../../common/dtos/instantiable.dto';

export class CpicRecommendationDto extends InstantiableDto<CpicRecommendationDto> {
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
