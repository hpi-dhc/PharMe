import { CpicRecommendation } from '../../common/cpic-api';
import { IGuideline_Any } from '../models/Guideline';
import { IMedication_DB } from '../models/Medication';

export function guidelineFromRecommendation(
    recommendation: CpicRecommendation,
): IGuideline_Any {
    return {
        lookupkey: recommendation.lookupkey,
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

export function medicationFromRecommendation(
    recommendation: CpicRecommendation,
): IMedication_DB {
    return {
        name: recommendation.drug.name,
        rxNorm: recommendation.drugid,
        drugclass: undefined,
        indication: undefined,
        guidelines: [],
    };
}
