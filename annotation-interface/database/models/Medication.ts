import mongoose, { Types } from 'mongoose';

import { IBaseModel, MongooseId, OptionalId } from '../helpers/types';
import { annotationBrickValidators } from './AbstractAnnotation';
import { IGuideline } from './Guideline';

export interface ILeanMedication<
    BrickIdT extends MongooseId,
    IdT extends OptionalId = undefined,
> extends Omit<IMedication<BrickIdT, IdT>, 'guidelines'> {
    guidelines: IdT[];
}

export interface IMedication<
    BrickIdT extends MongooseId,
    IdT extends OptionalId = undefined,
> extends IBaseModel<IdT> {
    name: string;
    rxNorm: string;
    drugclass?: BrickIdT[] | undefined;
    indication?: BrickIdT[] | undefined;
    guidelines: IGuideline<BrickIdT, IdT>[];
}

type MedicationModel = mongoose.Model<
    IMedication<Types.ObjectId, Types.ObjectId>
>;

const medicationSchema = new mongoose.Schema<
    IMedication<Types.ObjectId, Types.ObjectId>,
    MedicationModel
>({
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
      mongoose.model<
          IMedication<Types.ObjectId, Types.ObjectId>,
          MedicationModel
      >('Medication', medicationSchema);
