import { DrugWithGuidelines } from './cpic-constructors';
import { IGuideline_Any, IExternalData } from '../models/Guideline';

function externalDataInformationKey(externalData: IExternalData): string {
    return [
        externalData.comments ?? '',
        externalData.recommendation,
        ...Object.entries(externalData.implications).map(
            ([gene, implication]) => `${gene}${implication}`,
        ),
    ].join('');
}

// used to merge guidelines with equal information (e.g. when the same
// guideline is used for multiple phenotypes)
function phenotypeInformationKey(guideline: IGuideline_Any): string {
    return [
        ...Object.keys(guideline.phenotypes).map(
            (gene) => `${gene}${guideline.phenotypes[gene]}`,
        ),
        ...guideline.externalData
            .map((externalData) => externalDataInformationKey(externalData))
            .sort((a, b) => (a > b ? 1 : -1)),
    ].join('');
}

// merge same-information guidelines per phenotype if information matches (e.g.,
// different activity scores with same guideline)
// never merge FDA guidelines
function contractByPhenotypeAndInformation(
    drugsWithGuidelines: Array<DrugWithGuidelines>,
    source: string,
): Array<DrugWithGuidelines> {
    return drugsWithGuidelines.map(({ drug, guidelines }) => {
        // Do not concat FDA guidelines
        if (source == 'FDA') return { drug, guidelines };
        const phenotypeInformationMap = new Map<string, IGuideline_Any>();
        guidelines.forEach((guideline) => {
            const key = phenotypeInformationKey(guideline);
            if (phenotypeInformationMap.has(key)) {
                const existingGuideline = phenotypeInformationMap.get(key)!;
                // ensure that we don't miss information when
                // getting only first index from externalData
                const oneLookupPresent = Object.values(
                    guideline.lookupkey,
                ).every((value) => value.length == 1);
                if (!oneLookupPresent) {
                    throw Error('Expected only one lookup entry (per gene)');
                }
                Object.keys(existingGuideline.lookupkey).forEach((gene) => {
                    existingGuideline.lookupkey[gene].push(
                        guideline.lookupkey[gene][0],
                    );
                });
            } else {
                phenotypeInformationMap.set(key, guideline);
            }
        });
        return {
            drug,
            guidelines: Array.from(phenotypeInformationMap.values()),
        };
    });
}

// merge same-lookupkey guidelines (per activity score, if present; e.g. when a
// drug-lookupkey-pair has multiple different guidelines because the drug is
// used for different applications such as clopidogrel or has a pediatric
// guideline)
function contractByLookupkey(
    drugsWithGuidelines: Array<DrugWithGuidelines>,
): Array<DrugWithGuidelines> {
    return drugsWithGuidelines.map(({ drug, guidelines }) => {
        const lookupMap = new Map<string, IGuideline_Any>();
        guidelines.forEach((guideline) => {
            const key = Object.keys(guideline.lookupkey)
                .map((gene) => `${gene}${guideline.lookupkey[gene]}`)
                .join('');
            if (lookupMap.has(key)) {
                const existingGuideline = lookupMap.get(key)!;
                // ensure that we don't miss information when
                // getting only first index from externalData
                const oneGuidelinePresent = guideline.externalData.length == 1;
                if (!oneGuidelinePresent) {
                    throw Error('Expected only one externalData entry');
                }
                existingGuideline.externalData.push(guideline.externalData[0]);
            } else {
                lookupMap.set(key, guideline);
            }
        });
        return { drug, guidelines: Array.from(lookupMap.values()) };
    });
}

function contractRedundantExternalData(
    drugsWithGuidelines: Array<DrugWithGuidelines>,
): Array<DrugWithGuidelines> {
    return drugsWithGuidelines.map(({ drug, guidelines }) => {
        return {
            drug,
            guidelines: guidelines.map((guideline) => {
                const informationMap = new Map<string, IExternalData>();
                guideline.externalData.forEach((externalData) => {
                    const key = externalDataInformationKey(externalData);
                    if (!informationMap.has(key)) {
                        informationMap.set(key, externalData);
                    }
                });
                return {
                    ...guideline,
                    externalData: Array.from(informationMap.values()),
                };
            }),
        };
    });
}

export function contractGuidelines(
    drugsWithGuidelines: Array<DrugWithGuidelines>,
    source: string,
): Array<DrugWithGuidelines> {
    return contractRedundantExternalData(
        contractByPhenotypeAndInformation(
            contractByLookupkey(drugsWithGuidelines),
            source,
        ),
    );
}
