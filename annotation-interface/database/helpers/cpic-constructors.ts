import { CpicRecommendation } from '../../common/cpic-api';
import { IGuideline } from '../models/Guideline';
import { IMedication } from '../models/Medication';

export function guidelineFromRecommendation(
    recommendation: CpicRecommendation,
): IGuideline<string> {
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
): IMedication<string> {
    return {
        name: recommendation.drug.name,
        rxNorm: recommendation.drugid,
        drugclass: undefined,
        indication: undefined,
        guidelines: [],
    };
}
