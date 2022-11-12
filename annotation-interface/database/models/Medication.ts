import mongoose, { Types } from 'mongoose';

import {
    BrickAnnotationT,
    IBaseModel,
    MongooseId,
    OptionalId,
} from '../helpers/types';
import { annotationBrickValidators } from './AbstractAnnotation';
import Guideline, { IGuideline_Any, IGuideline_Str } from './Guideline';
import { ITextBrick_Str } from './TextBrick';

export interface IMedication<
    AnnotationT extends BrickAnnotationT,
    GuidelineT extends MongooseId | IGuideline_Any,
    IdT extends OptionalId = undefined,
> extends IBaseModel<IdT> {
    name: string;
    rxNorm: string;
    drugclass?: AnnotationT;
    indication?: AnnotationT;
    guidelines: GuidelineT[];
}
export type IMedication_DB = IMedication<
    Types.ObjectId[],
    Types.ObjectId,
    Types.ObjectId
> & {
    missingAnnotations: () => Promise<number>;
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

type MedicationModel = mongoose.Model<IMedication_DB>;

const medicationSchema = new mongoose.Schema<IMedication_DB, MedicationModel>({
    name: { type: String, required: true },
    rxNorm: { type: String, required: true },
    drugclass: {
        type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
        default: undefined,
        validate: annotationBrickValidators('Drug class'),
    },
    indication: {
        type: [{ type: Types.ObjectId, ref: 'TextBrick' }],
        default: undefined,
        validate: annotationBrickValidators('Drug indication'),
    },
    guidelines: {
        type: [{ type: Types.ObjectId, ref: 'Guideline' }],
        default: [],
    },
});

medicationSchema.methods.missingAnnotations = async function (
    this: IMedication_DB,
) {
    const medCount = [this.drugclass, this.indication].filter(
        (annotation) => !annotation,
    ).length;

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

export default !mongoose.models
    ? undefined
    : (mongoose.models.Medication as MedicationModel) ||
      mongoose.model<IMedication_DB, MedicationModel>(
          'Medication',
          medicationSchema,
      );
