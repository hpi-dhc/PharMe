import mongoose, { Document, Types } from 'mongoose';

import { SupportedLanguage } from '../../common/definitions';
import {
    BrickAnnotationT,
    CurationState,
    IAnnotationDoc,
} from '../helpers/annotations';
import { brickAnnotationValidators } from '../helpers/brick-validators';
import { BrickResolver, resolveStringOrFail } from '../helpers/resolve-bricks';
import { makeIdsStrings, MongooseId, OptionalId } from '../helpers/types';
import { versionedModel } from '../versioning/schema';
import Guideline, {
    IGuideline_Any,
    IGuideline_DB,
    IGuideline_Resolved,
    IGuideline_Str,
} from './Guideline';
import { ITextBrick_DB, ITextBrick_Str } from './TextBrick';

export interface IDrug<
    AnnotationT extends BrickAnnotationT,
    GuidelineT extends MongooseId | IGuideline_Any,
    IdT extends OptionalId = undefined,
> extends IAnnotationDoc<
        IdT,
        {
            drugclass?: AnnotationT;
            indication?: AnnotationT;
            brandNames?: string[];
        }
    > {
    name: string;
    rxNorm: string;
    guidelines: GuidelineT[];
}

export type IDrug_DB = IDrug<
    Types.ObjectId[],
    Types.ObjectId,
    Types.ObjectId
> & {
    curationState: () => Promise<CurationState>;
    resolve: (language: SupportedLanguage) => Promise<IDrug_Resolved>;
};
export type IDrug_Str = IDrug<string, IGuideline_Str, string>;
export type IDrug_Populated = IDrug<
    Array<ITextBrick_Str>,
    IGuideline_Str,
    string
>;
export type IDrug_Any = IDrug<
    BrickAnnotationT,
    MongooseId | IGuideline_Any,
    OptionalId
>;
export type IDrug_Resolved = IDrug<string, IGuideline_Resolved, string>;

const { schema, makeModel } = versionedModel<IDrug_DB>('Drug', {
    name: { type: String, required: true },
    rxNorm: { type: String, required: true },
    annotations: {
        type: {
            drugclass: {
                type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
                default: undefined,
                validate: brickAnnotationValidators('Drug class'),
            },
            indication: {
                type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
                default: undefined,
                validate: brickAnnotationValidators('Drug indication'),
            },
            brandNames: { type: [String], default: undefined },
        },
        required: true,
    },
    guidelines: {
        type: [{ type: Types.ObjectId, ref: 'Guideline' }],
        default: [],
    },
    isStaged: { type: Boolean, required: true, default: false },
});

schema.methods.curationState = async function (
    this: IDrug_DB,
): Promise<CurationState> {
    const annotations = [
        this.annotations.drugclass,
        this.annotations.indication,
        this.annotations.brandNames,
    ];
    const curationState: CurationState = {
        total: annotations.length,
        curated: annotations.filter((annotation) => !!annotation).length,
    };

    const guidelineStates = await Promise.all(
        this.guidelines.map(async (id) => {
            const guideline = await Guideline!.findById(id);
            return guideline?.curationState;
        }),
    );

    return guidelineStates.reduce((total, current) => {
        return {
            total: total!.total + (current?.total ?? 0),
            curated: total!.curated + (current?.curated ?? 0),
        };
    }, curationState)!;
};

type IDrug_FullyPopulated = IDrug<
    Array<ITextBrick_DB>,
    IGuideline_DB,
    Types.ObjectId
>;
schema.methods.resolve = async function (
    this: Document<unknown, unknown, IDrug_FullyPopulated> &
        IDrug_FullyPopulated,
    language: SupportedLanguage,
): Promise<IDrug_Resolved> {
    try {
        // resolve drug annotations
        await this.populate([
            'annotations.drugclass',
            'annotations.indication',
        ]);
        const resolved = makeIdsStrings(this);
        const drugResolver: BrickResolver = { from: 'drug', with: this };
        resolved.annotations.drugclass = resolveStringOrFail(
            drugResolver,
            this.annotations.drugclass,
            language,
        );
        resolved.annotations.indication = resolveStringOrFail(
            drugResolver,
            this.annotations.indication,
            language,
        );
        // resolve guideline annotations
        await this.populate('guidelines');
        const guidelines = await Promise.all(
            this.guidelines
                .filter((guideline) => guideline.isStaged)
                .map((guideline) => guideline.resolve(this.name, language)),
        );
        resolved.guidelines = guidelines;
        return resolved;
    } catch (error) {
        /* eslint-disable @typescript-eslint/no-explicit-any */
        const message =
            error && typeof error === 'object'
                ? (error as any)['message']
                : undefined;
        throw new Error(
            `Unable to resolve Drug ${this.name}${
                message ? `: ${message}` : ''
            }`,
        );
    }
};

export default !mongoose.models ? undefined : makeModel();
