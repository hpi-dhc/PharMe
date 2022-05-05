import { IsOptional } from 'class-validator';

interface ExternalIdentifier {
    resource: 'PharmGKB' | string;
    identifier: string;
}
interface InternationalBrand {
    name: string;
}

export class DrugDto {
    name: string;

    @IsOptional()
    description: string;

    @IsOptional()
    'external-identifiers': {
        'external-identifier': Array<ExternalIdentifier> | ExternalIdentifier;
    };

    @IsOptional()
    'international-brands': {
        'international-brand': Array<InternationalBrand> | InternationalBrand;
    };
}
