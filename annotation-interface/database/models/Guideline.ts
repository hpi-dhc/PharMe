import mongoose, { Document, Types } from 'mongoose';

import {
    SupportedLanguage,
    WarningLevel,
    warningLevelValues,
} from '../../common/definitions';
import { brickAnnotationValidators } from '../helpers/brick-validators';
import { missingGuidelineAnnotations } from '../helpers/guideline-data';
import { BrickResolver, resolveStringOrFail } from '../helpers/resolve-bricks';
import {
    BrickAnnotationT,
    IAnnotationModel,
    makeIdsStrings,
    OptionalId,
} from '../helpers/types';
import { ITextBrick_Str } from './TextBrick';

export interface IGuideline<
    AnnotationT extends BrickAnnotationT,
    IdT extends OptionalId = undefined,
> extends IAnnotationModel<
        IdT,
        {
            recommendation?: AnnotationT;
            implication?: AnnotationT;
            warningLevel?: WarningLevel;
        }
    > {
    lookupkey: { [key: string]: [string] }; // gene-symbol: phenotype-description
    cpicData: {
        recommendationId: number;
        recommendationVersion: number;
        guidelineName: string;
        guidelineUrl: string;
        implications: { [key: string]: string }; // gene-symbol: implication
        recommendation: string;
        comments?: string;
    };
}
export type IGuideline_DB = IGuideline<Types.ObjectId[], Types.ObjectId> & {
    missingAnnotations: number;
    resolve: (
        drugName: string,
        language: SupportedLanguage,
    ) => Promise<IGuideline_Resolved>;
};
export type IGuideline_Str = IGuideline<string, string>;
export type IGuideline_Populated = IGuideline<ITextBrick_Str[], string>;
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
    annotations: {
        type: {
            recommendation: {
                type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
                default: undefined,
                validate: brickAnnotationValidators('Recommendation'),
            },
            implication: {
                type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
                default: undefined,
                validate: brickAnnotationValidators('Implication'),
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
        return missingGuidelineAnnotations(this);
    });

guidelineSchema.methods.resolve = async function (
    this: Document<unknown, unknown, IGuideline_Populated> &
        IGuideline_Populated,
    drugName: string,
    language: SupportedLanguage,
): Promise<IGuideline_Resolved> {
    await this.populate([
        'annotations.implication',
        'annotations.recommendation',
    ]);
    const resolved = makeIdsStrings(this);
    const resolver: BrickResolver = {
        from: 'guideline',
        with: { drugName, guideline: this },
    };
    resolved.annotations.implication = resolveStringOrFail(
        resolver,
        this.annotations.implication,
        language,
    );
    resolved.annotations.recommendation = resolveStringOrFail(
        resolver,
        this.annotations.recommendation,
        language,
    );
    return resolved;
};

export default !mongoose.models
    ? undefined
    : (mongoose.models.Guideline as GuidelineModel) ||
      mongoose.model<IGuideline_DB, GuidelineModel>(
          'Guideline',
          guidelineSchema,
      );
