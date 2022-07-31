import { IsNotEmpty, IsNumber, IsString, IsUrl } from 'class-validator';

import { InstantiableDto } from '../../common/dtos/instantiable.dto';

export class CpicGuidelineDto extends InstantiableDto<CpicGuidelineDto> {
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
