import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';

import { ClinicalAnnotation } from './interfaces/clinicalAnnotation.interface';

export async function getClinicalAnnotations(
    httpService: HttpService,
    relatedChemicalId: string,
): Promise<ClinicalAnnotation[]> {
    const response = await lastValueFrom(
        httpService.get('https://api.pharmgkb.org/v1/data/clinicalAnnotation', {
            params: {
                'relatedChemicals.accessionId': relatedChemicalId,
            },
        }),
    );
    return response.data.data;
}
