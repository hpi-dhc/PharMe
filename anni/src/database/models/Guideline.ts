import mongoose, { Document, Types } from 'mongoose';

import { ITextBrick_Str } from './TextBrick';
import {
    SupportedLanguage,
    WarningLevel,
    warningLevelValues,
} from '../../common/definitions';
import {
    BrickAnnotationT,
    CurationState,
    IAnnotationDoc,
} from '../helpers/annotations';
import { brickAnnotationValidators } from '../helpers/brick-validators';
import { guidelineCurationState } from '../helpers/guideline-data';
import { BrickResolver, resolveStringOrFail } from '../helpers/resolve-bricks';
import { makeIdsStrings, OptionalId } from '../helpers/types';
import { versionedModel } from '../versioning/schema';

export interface IGuideline<
    AnnotationT extends BrickAnnotationT,
    IdT extends OptionalId = undefined,
> extends IAnnotationDoc<
        IdT,
        {
            recommendation?: AnnotationT;
            implication?: AnnotationT;
            warningLevel?: WarningLevel;
        }
    > {
    lookupkey: { [key: string]: [string] }; // gene-symbol: phenotype-description
    externalData: {
        source: string;
        recommendationId?: number;
        recommendationVersion?: number;
        guidelineName: string;
        guidelineUrl: string;
        implications: { [key: string]: string }; // gene-symbol: implication
        recommendation: string;
        comments?: string;
    };
}
export type IGuideline_DB = IGuideline<Types.ObjectId[], Types.ObjectId> & {
    curationState: CurationState;
    resolve: (
        drugName: string,
        language: SupportedLanguage,
    ) => Promise<IGuideline_Resolved>;
};
export type IGuideline_Str = IGuideline<string, string>;
export type IGuideline_Populated = IGuideline<ITextBrick_Str[], string>;
export type IGuideline_Any = IGuideline<BrickAnnotationT, OptionalId>;
export type IGuideline_Resolved = IGuideline<string, OptionalId>;

const { schema, makeModel } = versionedModel<IGuideline_DB>('Guideline', {
    lookupkey: { type: {}, required: true },
    externalData: {
        type: {
            source: { type: String, required: true },
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
    isStaged: { type: Boolean, required: true, default: false },
});

schema.pre<IGuideline_DB>('validate', function (next) {
    if (
        JSON.stringify(Object.keys(this.lookupkey)) !==
        JSON.stringify(Object.keys(this.externalData.implications))
    ) {
        next(
            new Error(
                `Lookup-Key inconsistent with CPIC implications (recommendationid: ${this.externalData.recommendationId})`,
            ),
        );
    }
    next();
});

schema.virtual('curationState').get(function (this: IGuideline_DB) {
    return guidelineCurationState(this);
});

schema.methods.resolve = async function (
    this: Document<unknown, unknown, IGuideline_Populated> &
        IGuideline_Populated,
    drugName: string,
    language: SupportedLanguage,
): Promise<IGuideline_Resolved> {
    try {
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
        if (this.annotations.warningLevel === undefined)
            throw new Error('Warning level missing.');
        return resolved;
    } catch (error) {
        /* eslint-disable @typescript-eslint/no-explicit-any */
        const message =
            error && typeof error === 'object'
                ? (error as any)['message']
                : undefined;
        throw new Error(
            `Unable to resolve Guideline ${this.externalData.guidelineName}${
                message ? `: ${message}` : ''
            }`,
        );
    }
};

export default !mongoose.models ? undefined : makeModel();
