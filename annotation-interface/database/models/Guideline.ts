import mongoose, { Types } from 'mongoose';

import { WarningLevel, warningLevelValues } from '../../common/server-types';
import { BrickAnnotationT, IBaseModel, OptionalId } from '../helpers/types';
import { annotationBrickValidators } from './AbstractAnnotation';

export interface IGuideline<
    AnnotationT extends BrickAnnotationT,
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
        recommendation?: AnnotationT;
        implication?: AnnotationT;
        warningLevel?: WarningLevel;
    };
}
export type IGuideline_DB = IGuideline<Types.ObjectId[], Types.ObjectId> & {
    missingAnnotations: number;
};
export type IGuideline_Any = IGuideline<BrickAnnotationT, OptionalId>;
export type IGuideline_Resolved = IGuideline<string, OptionalId>;

type GuidelineModel = mongoose.Model<IGuideline_DB>;

const guidelineSchema = new mongoose.Schema<IGuideline_DB, GuidelineModel>({
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

guidelineSchema.pre<IGuideline_DB>('validate', function (next) {
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
});

guidelineSchema
    .virtual('missingAnnotations')
    .get(function (this: IGuideline_DB) {
        return [
            this.pharMeData.implication,
            this.pharMeData.recommendation,
            this.pharMeData.warningLevel,
        ].filter((annotation) => !annotation).length;
    });

export default !mongoose.models
    ? undefined
    : (mongoose.models.Guideline as GuidelineModel) ||
      mongoose.model<IGuideline_DB, GuidelineModel>(
          'Guideline',
          guidelineSchema,
      );
