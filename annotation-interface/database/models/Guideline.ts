import mongoose, { Types } from 'mongoose';

import { WarningLevel, warningLevelValues } from '../../common/server-types';
import { IBaseModel, MongooseId, OptionalId } from '../helpers/types';
import { annotationBrickValidators } from './AbstractAnnotation';

export interface IGuideline<
    BrickIdT extends MongooseId,
    IdT extends OptionalId = undefined,
> extends IBaseModel<IdT> {
    lookupkey: { [key: string]: string }; // gene-symbol: phenotype
    cpicData: {
        recommendationId: number;
        recommendationVersion: number;
        guidelineName: string;
        guidelineUrl: string;
        implications: { [key: string]: string }; // gene-symbol: implication
        recommendation: string;
        comments?: string;
    };
    pharMeData: {
        recommendation?: BrickIdT[];
        implication?: BrickIdT[];
        warningLevel?: WarningLevel;
    };
}

type GuidelineModel = mongoose.Model<
    IGuideline<Types.ObjectId, Types.ObjectId>
>;

const guidelineSchema = new mongoose.Schema<
    IGuideline<Types.ObjectId, Types.ObjectId>,
    GuidelineModel
>({
    lookupkey: { type: {}, required: true },
    cpicData: {
        type: {
            recommendationId: { type: Number, required: true, index: true },
            recommendationVersion: { type: Number, required: true },
            guidelineName: { type: String, required: true },
            guidelineUrl: { type: String, required: true },
            implications: { type: {}, required: true },
            recommendation: { type: String, required: true },
            comments: String,
        },
        required: true,
    },
    pharMeData: {
        type: {
            recommendation: {
                type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
                default: undefined,
                validate: annotationBrickValidators('Recommendation'),
            },
            implication: {
                type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
                default: undefined,
                validate: annotationBrickValidators('Implication'),
            },
            warningLevel: {
                type: String,
                enum: warningLevelValues,
                default: undefined,
            },
        },
        required: true,
    },
});

guidelineSchema.pre<IGuideline<Types.ObjectId, Types.ObjectId>>(
    'validate',
    function (next) {
        if (
            JSON.stringify(Object.keys(this.lookupkey)) !==
            JSON.stringify(Object.keys(this.cpicData.implications))
        ) {
            next(
                new Error(
                    `Lookup-Key inconsistent with CPIC implications (recommendationid: ${this.cpicData.recommendationId})`,
                ),
            );
        }
        next();
    },
);

export default !mongoose.models
    ? undefined
    : (mongoose.models.Guideline as GuidelineModel) ||
      mongoose.model<
          IGuideline<Types.ObjectId, Types.ObjectId>,
          GuidelineModel
      >('Guideline', guidelineSchema);
