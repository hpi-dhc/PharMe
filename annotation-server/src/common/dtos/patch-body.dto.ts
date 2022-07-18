import { ParseArrayOptions, ParseArrayPipe } from '@nestjs/common';
import {
    IntersectionType,
    OmitType,
    PartialType,
    PickType,
} from '@nestjs/mapped-types';

import { Guideline } from '../../guidelines/entities/guideline.entity';
import { Medication } from '../../medications/medication.entity';

export class PatchMedicationDto extends IntersectionType(
    PickType(Medication, ['id'] as const),
    PartialType(Medication),
) {}

export class PatchGuidelineDto extends IntersectionType(
    PickType(Guideline, ['id'] as const),
    OmitType(PartialType(Guideline), ['id'] as const),
) {}

export function getPatchArrayPipe(
    items: ParseArrayOptions['items'],
): ParseArrayPipe {
    return new ParseArrayPipe({
        items,
        whitelist: true,
        forbidNonWhitelisted: true,
    });
}
