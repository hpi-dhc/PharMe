import { contractGuidelines } from './contraction-utils';
import { CpicRecommendation } from '../../common/cpic-api';
import { IDrug_Any } from '../models/Drug';
import { IGuideline_Any } from '../models/Guideline';

export interface DrugWithGuidelines {
    drug: IDrug_Any;
    guidelines: Array<IGuideline_Any>;
}

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

export function getDrugsWithGuidelines(
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

    return contractGuidelines(Array.from(drugIdMap.values()), source);
}

export function getAdditionalDrugs(
    drugs: Array<CpicRecommendation>,
): Array<DrugWithGuidelines> {
    return drugs.map((drug) => {
        return {
            drug: drugFromRecommendation(drug),
            guidelines: [],
        };
    });
}
