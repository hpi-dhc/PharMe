import mongoose, { Types } from 'mongoose';

import {
    BrickAnnotationT,
    IBaseModel,
    MongooseId,
    OptionalId,
} from '../helpers/types';
import { annotationBrickValidators } from './AbstractAnnotation';
import { IGuideline } from './Guideline';

export interface IMedication<
    AnnotationT extends BrickAnnotationT,
    GuidelineT extends MongooseId | IGuideline<BrickAnnotationT, OptionalId>,
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

export default !mongoose.models
    ? undefined
    : (mongoose.models.Medication as MedicationModel) ||
      mongoose.model<IMedication_DB, MedicationModel>(
          'Medication',
          medicationSchema,
      );
