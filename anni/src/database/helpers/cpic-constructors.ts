import { CpicRecommendation } from '../../common/cpic-api';
import { IDrug_Any } from '../models/Drug';
import { IGuideline_Any } from '../models/Guideline';

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
function guidelineKey(recommendation: CpicRecommendation) {
    return [
        recommendation.drugid,
        recommendation.comments ?? '',
        recommendation.drugrecommendation,
        ...Object.entries(recommendation.implications).map(
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
    return Object.keys(guideline.lookupkey)
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

export interface DrugWithGuidelines {
    drug: IDrug_Any;
    guidelines: Array<IGuideline_Any>;
}
export function getDrugsWithContractedGuidelines(
    recommendations: Array<CpicRecommendation>,
    source: string,
): Array<DrugWithGuidelines> {
    const guidelineKeyMap = new Map<string, IGuideline_Any>();
    const drugIdMap = new Map<string, DrugWithGuidelines>();

    // merge same-information guidelines
    function processContractedGuideline(
        rec: CpicRecommendation,
    ): IGuideline_Any | null {
        const key = guidelineKey(rec);
        if (guidelineKeyMap.has(key)) {
            const existingGuideline = guidelineKeyMap.get(key);
            Object.keys(existingGuideline!.lookupkey).forEach((gene) => {
                existingGuideline!.lookupkey[gene].push(rec.lookupkey[gene]);
            });
            Object.keys(existingGuideline!.phenotypes).forEach((gene) => {
                existingGuideline!.phenotypes[gene].push(rec.phenotypes[gene]);
            });
            return null;
        }
        const guideline = guidelineFromRecommendation(rec, source);
        guidelineKeyMap.set(key, guideline);
        return guideline;
    }

    recommendations.forEach((rec) => {
        const newGuideline = processContractedGuideline(rec);
        const existing = drugIdMap.get(rec.drugid);
        if (existing && newGuideline) {
            existing.guidelines.push(newGuideline);
        }
        if (!existing) {
            drugIdMap.set(rec.drugid, {
                drug: drugFromRecommendation(rec),
                guidelines: newGuideline ? [newGuideline] : [],
            });
        }
    });

    // merge same-phenotype guidelines
    return Array.from(drugIdMap.values()).map(({ drug, guidelines }) => {
        const phenotypeMap = new Map<string, IGuideline_Any>();
        guidelines.forEach((guideline) => {
            const key = phenotypeKey(guideline);
            if (phenotypeMap.has(key)) {
                phenotypeMap
                    .get(key)!
                    .externalData.push(guideline.externalData[0]);
            } else {
                phenotypeMap.set(key, guideline);
            }
        });
        return { drug, guidelines: Array.from(phenotypeMap.values()) };
    });
}
