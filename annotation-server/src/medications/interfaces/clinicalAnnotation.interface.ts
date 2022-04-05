export interface ClinicalAnnotation {
    allelePhenotypes: [
        {
            allele: string;
            phenotype: string;
        },
    ];
    location: {
        genes: [{ symbol: string }];
    };
}
