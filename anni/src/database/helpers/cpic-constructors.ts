import { CpicRecommendation } from '../../common/cpic-api';
import { IDrug_Any } from '../models/Drug';
import { IGuideline_Any, IExternalData } from '../models/Guideline';

function guidelineFromRecommendation(
    recommendation: CpicRecommendation,
    source: string,
): IGuideline_Any {
    // make lookupkey and phenotype lists for merging later and add
    // lookupkeys as phenotypes if phenotypes are missing
    const lookupkey = new Object() as { [key: string]: [string] };
    const phenotypes = new Object() as { [key: string]: [string] };
    Object.keys(recommendation.lookupkey).forEach((gene) => {
        lookupkey[gene] = [recommendation.lookupkey[gene]];
        phenotypes[gene] =
            gene in recommendation.phenotypes
                ? [recommendation.phenotypes[gene]]
                : [recommendation.lookupkey[gene]];
    });
    return {
        lookupkey,
        phenotypes,
        externalData: [
            {
                source,
                recommendationId: recommendation.id,
                recommendationVersion: recommendation.version,
                guidelineName: recommendation.guideline.name,
                guidelineUrl: recommendation.guideline.url,
                implications: recommendation.implications,
                recommendation: recommendation.drugrecommendation,
                comments: recommendation.comments,
            },
        ],
        annotations: {
            recommendation: undefined,
            implication: undefined,
            warningLevel: undefined,
        },
        isStaged: false,
    };
}

// used to merge guidelines with equal information (e.g. when the same
// guideline is used for multiple phenotypes)
function informationKey(externalData: IExternalData): string {
    return [
        externalData.comments ?? '',
        externalData.recommendation,
        ...Object.entries(externalData.implications).map(
            ([gene, implication]) => `${gene}${implication}`,
        ),
    ].join('');
}

// used to merge guidelines with same lookupkeys/phenotypes (e.g. when a
// drug-phenotype-pair has multiple different guideline because the drug is
// used for different applications such as clopidogrel or when multiple
// lookupkeys match to the same phenotye, as it often is the case for
// activity scores)
function phenotypeKey(guideline: IGuideline_Any): string {
    return Object.keys(guideline.phenotypes)
        .map((gene) => `${gene}${guideline.phenotypes[gene]}`)
        .join('');
}

function drugFromRecommendation(recommendation: CpicRecommendation): IDrug_Any {
    return {
        name: recommendation.drug.name,
        rxNorm: recommendation.drugid,
        annotations: {
            drugclass: undefined,
            indication: undefined,
        },
        guidelines: [],
        isStaged: false,
    };
}

// initially (before contracting) guideline.externalData and values
// (phenotype descriptions) of guideline.lookupkey should be of length
// 1, as we set it this way ourselves in guidelineFromRecommendation
function ensureInitialGuidelineStructure(guideline: IGuideline_Any) {
    if (
        guideline.externalData.length != 1 ||
        !Object.values(guideline.lookupkey).every((value) => value.length == 1)
    ) {
        throw Error('Expected different initial guideline data structure');
    }
}

// merge same-phenotype guidelines
function contractByPhenotype(
    drugsWithGuidelines: Array<DrugWithGuidelines>,
): Array<DrugWithGuidelines> {
    return drugsWithGuidelines.map(({ drug, guidelines }) => {
        const phenotypeMap = new Map<string, IGuideline_Any>();
        guidelines.forEach((guideline) => {
            const key = phenotypeKey(guideline);
            const existingGuideline = phenotypeMap.get(key);
            if (existingGuideline) {
                // ensure that we don't miss information when
                // getting only first index from externalData
                // and lookupkey[gene]
                ensureInitialGuidelineStructure(guideline);
                existingGuideline.externalData.push(guideline.externalData[0]);
                Object.keys(existingGuideline.lookupkey).forEach((gene) => {
                    existingGuideline.lookupkey[gene].push(
                        guideline.lookupkey[gene][0],
                    );
                });
            } else {
                phenotypeMap.set(key, guideline);
            }
        });
        return { drug, guidelines: Array.from(phenotypeMap.values()) };
    });
}

// merge same-information guidelines
function contractByInformation(
    drugsWithGuidelines: Array<DrugWithGuidelines>,
): Array<DrugWithGuidelines> {
    return drugsWithGuidelines.map(({ drug, guidelines }) => {
        guidelines.forEach((guideline) => {
            const informationMap = new Map<string, IExternalData>();
            guideline.externalData.forEach((externalData) => {
                const key = informationKey(externalData);
                if (!informationMap.has(key)) {
                    informationMap.set(key, externalData);
                }
            });
            guideline.externalData = Array.from(informationMap.values());
        });
        return { drug, guidelines };
    });
}

export interface DrugWithGuidelines {
    drug: IDrug_Any;
    guidelines: Array<IGuideline_Any>;
}
export function getDrugsWithContractedGuidelines(
    recommendations: Array<CpicRecommendation>,
    source: string,
): Array<DrugWithGuidelines> {
    const drugIdMap = new Map<string, DrugWithGuidelines>();
    recommendations.forEach((rec) => {
        const newGuideline = guidelineFromRecommendation(rec, source);
        const existing = drugIdMap.get(rec.drugid);
        if (existing) {
            existing.guidelines.push(newGuideline);
        } else {
            drugIdMap.set(rec.drugid, {
                drug: drugFromRecommendation(rec),
                guidelines: [newGuideline],
            });
        }
    });

    return contractByInformation(
        contractByPhenotype(Array.from(drugIdMap.values())),
    );
}
