interface ExternalIdentifier {
    resource: 'PharmGKB' | string;
    identifier: string;
}
interface InternationalBrand {
    name: string;
}

export interface Drug {
    name: string;
    description?: string;
    'external-identifiers'?: {
        'external-identifier': Array<ExternalIdentifier> | ExternalIdentifier;
    };
    'international-brands'?: {
        'international-brand': Array<InternationalBrand> | InternationalBrand;
    };
}
