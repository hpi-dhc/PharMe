import mongoose, { Document, Types } from 'mongoose';

import { SupportedLanguage } from '../../common/definitions';
import { brickAnnotationValidators } from '../helpers/brick-validators';
import { BrickResolver, resolveStringOrFail } from '../helpers/resolve-bricks';
import {
    BrickAnnotationT,
    IAnnotationModel,
    makeIdsStrings,
    MongooseId,
    OptionalId,
} from '../helpers/types';
import Guideline, {
    IGuideline_Any,
    IGuideline_DB,
    IGuideline_Resolved,
    IGuideline_Str,
} from './Guideline';
import { ITextBrick_DB, ITextBrick_Str } from './TextBrick';

export interface IMedication<
    AnnotationT extends BrickAnnotationT,
    GuidelineT extends MongooseId | IGuideline_Any,
    IdT extends OptionalId = undefined,
> extends IAnnotationModel<
        IdT,
        {
            drugclass?: AnnotationT;
            indication?: AnnotationT;
        }
    > {
    name: string;
    rxNorm: string;
    guidelines: GuidelineT[];
}

export type IMedication_DB = IMedication<
    Types.ObjectId[],
    Types.ObjectId,
    Types.ObjectId
> & {
    missingAnnotations: () => Promise<number>;
    resolve: (language: SupportedLanguage) => Promise<IMedication_Resolved>;
};
export type IMedication_Str = IMedication<string, IGuideline_Str, string>;
export type IMedication_Populated = IMedication<
    Array<ITextBrick_Str>,
    IGuideline_Str,
    string
>;
export type IMedication_Any = IMedication<
    BrickAnnotationT,
    MongooseId | IGuideline_Any,
    OptionalId
>;
export type IMedication_Resolved = IMedication<
    string,
    IGuideline_Resolved,
    string
>;

type MedicationModel = mongoose.Model<IMedication_DB>;

const medicationSchema = new mongoose.Schema<IMedication_DB, MedicationModel>({
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
        },
        required: true,
    },
    guidelines: {
        type: [{ type: Types.ObjectId, ref: 'Guideline' }],
        default: [],
    },
});

medicationSchema.methods.missingAnnotations = async function (
    this: IMedication_DB,
) {
    const medCount = [
        this.annotations.drugclass,
        this.annotations.indication,
    ].filter((annotation) => !annotation).length;

    const guidelineCounts = await Promise.all(
        this.guidelines.map(async (id) => {
            const guideline = await Guideline!.findById(id);
            return guideline?.missingAnnotations;
        }),
    );

    return guidelineCounts.reduce(
        (total, current) => total! + (current ?? 0),
        medCount,
    );
};

type IMedication_FullyPopulated = IMedication<
    Array<ITextBrick_DB>,
    IGuideline_DB,
    Types.ObjectId
>;
medicationSchema.methods.resolve = async function (
    this: Document<unknown, unknown, IMedication_FullyPopulated> &
        IMedication_FullyPopulated,
    language: SupportedLanguage,
): Promise<IMedication_Resolved> {
    // resolve drug annotations
    await this.populate(['annotations.drugclass', 'annotations.indication']);
    const resolved = makeIdsStrings(this);
    const drugResolver: BrickResolver = {
        from: 'medication',
        with: this,
    };
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
        this.guidelines.map((guideline) =>
            guideline.resolve(this.name, language),
        ),
    );
    resolved.guidelines = guidelines;
    return resolved;
};

export default !mongoose.models
    ? undefined
    : (mongoose.models.Medication as MedicationModel) ||
      mongoose.model<IMedication_DB, MedicationModel>(
          'Medication',
          medicationSchema,
      );
