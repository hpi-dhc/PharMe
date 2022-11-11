import { CpicRecommendation } from '../../common/cpic-api';
import { IGuideline_Any } from '../models/Guideline';
import { IMedication_Any } from '../models/Medication';

function guidelineFromRecommendation(
    recommendation: CpicRecommendation,
): IGuideline_Any {
    return {
        lookupkey: Object.entries(recommendation.lookupkey).reduce(
            (lookupkey, [gene, phenotype]) => {
                lookupkey[gene] = [phenotype];
                return lookupkey;
            },
            new Object() as { [key: string]: [string] },
        ),
        cpicData: {
            recommendationId: recommendation.id,
            recommendationVersion: recommendation.version,
            guidelineName: recommendation.guideline.name,
            guidelineUrl: recommendation.guideline.url,
            implications: recommendation.implications,
            recommendation: recommendation.drugrecommendation,
            comments: recommendation.comments,
        },
        pharMeData: {
            recommendation: undefined,
            implication: undefined,
            warningLevel: undefined,
        },
    };
}

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

function drugFromRecommendation(
    recommendation: CpicRecommendation,
): IMedication_Any {
    return {
        name: recommendation.drug.name,
        rxNorm: recommendation.drugid,
        drugclass: undefined,
        indication: undefined,
        guidelines: [],
    };
}

interface DrugWithGuidelines {
    drug: IMedication_Any;
    guidelines: Array<IGuideline_Any>;
}
export function getDrugsWithContractedGuidelines(
    recommendations: Array<CpicRecommendation>,
): Array<DrugWithGuidelines> {
    const guidelineKeyMap = new Map<string, IGuideline_Any>();
    const drugIdMap = new Map<string, DrugWithGuidelines>();

    function processContractedGuideline(
        rec: CpicRecommendation,
    ): IGuideline_Any | null {
        const key = guidelineKey(rec);
        if (guidelineKeyMap.has(key)) {
            const existing = guidelineKeyMap.get(key)!.lookupkey;
            Object.keys(existing).forEach((gene) => {
                existing[gene].push(rec.lookupkey[gene]);
            });
            return null;
        }
        const guideline = guidelineFromRecommendation(rec);
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

    return Array.from(drugIdMap.values());
}
