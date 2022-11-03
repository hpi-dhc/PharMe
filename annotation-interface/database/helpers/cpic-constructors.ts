import { Types } from 'mongoose';

import { CpicRecommendation } from '../../common/cpic-api';
import { ILeanMedication } from '../../database/models/Medication';
import { IGuideline } from '../models/Guideline';

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
): ILeanMedication<Types.ObjectId, Types.ObjectId> {
    return {
        name: recommendation.drug.name,
        rxNorm: recommendation.drugid,
        drugclass: undefined,
        indication: undefined,
        guidelines: [],
    };
}
