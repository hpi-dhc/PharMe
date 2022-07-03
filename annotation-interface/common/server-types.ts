export const warningLevelValues = ['ok', 'warning', 'danger'] as const;
export type WarningLevel = typeof warningLevelValues[number];

export type ServerGuidelineOverview = {
    id: number;
    implication: string | null;
    recommendation: string | null;
    warningLevel: WarningLevel | null;
    medication: ServerMedication;
    phenotype: {
        geneResult: { name: string };
        geneSymbol: { name: string };
    };
};

export type ServerGuideline = ServerGuidelineOverview & {
    cpicGuidelineName: string;
    cpicGuidelineUrl: string;
    cpicRecommendation: string;
    cpicImplication: string;
    cpicClassification: string;
    cpicComment: string | null;
    phenotype: {
        cpicConsultationText: string | null;
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

const serverEndpoint = `http://${process.env.AS_API}/`;
export const serverEndpointInit = serverEndpoint + 'init/';
export const serverEndpointMeds = (query?: string): string =>
    `${serverEndpoint}medications/${query ?? ''}`;
export const serverEndpointGuidelines = (query?: string): string =>
    `${serverEndpoint}guidelines/${query ?? ''}`;
