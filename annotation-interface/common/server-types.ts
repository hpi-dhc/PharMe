export type WarningLevel = 'ok' | 'warning' | 'danger';

export type ServerGuidelineOverview = {
    id: number;
    implication: string | null;
    recommendation: string | null;
    warningLevel: WarningLevel | null;
    medication: { name: string };
    phenotype: {
        geneResult: { name: string };
        geneSymbol: { name: string };
    };
};

export type ServerMedication = {
    id: number;
    name: string;
    // not nullable since a medication can only get guidelines if it has an rxcui
    // and we are only fetching medications with guidelines
    rxcui: string;
    drugclass: string | null;
    indication: string | null;
};
