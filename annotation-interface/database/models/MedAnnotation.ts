import mongoose, { Types } from 'mongoose';

import { ServerMedication } from '../../common/server-types';
import { MongooseId, OptionalId } from '../helpers/types';
import AbstractAnnotation, {
    annotationBrickValidators,
    IAbstractAnnotation,
} from './AbstractAnnotation';

export interface IMedAnnotation<
    BrickIdT extends MongooseId,
    IdT extends OptionalId = undefined,
> extends IAbstractAnnotation<IdT> {
    drugclass?: BrickIdT[] | undefined;
    indication?: BrickIdT[] | undefined;
}

interface MedAnnotationModel
    extends mongoose.Model<IMedAnnotation<Types.ObjectId, Types.ObjectId>> {
    findMatching(serverMed: ServerMedication): ReturnType<typeof findMatching>;
}

const medAnnotationSchema = new mongoose.Schema<
    IMedAnnotation<Types.ObjectId, Types.ObjectId>,
    MedAnnotationModel
>({
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
});

medAnnotationSchema.pre<IMedAnnotation<Types.ObjectId, Types.ObjectId>>(
    'validate',
    function (next) {
        if (!this.drugclass && !this.indication)
            next(new Error('At least one category needs to be defined'));
        next();
    },
);

function findMatching(this: MedAnnotationModel, serverMed: ServerMedication) {
    return this.findOne({ medicationRxCUI: serverMed.rxcui });
}
medAnnotationSchema.static('findMatching', findMatching);

export default !mongoose.models
    ? undefined
    : (mongoose.models.MedAnnotation as MedAnnotationModel) ||
      AbstractAnnotation!.discriminator<
          IMedAnnotation<Types.ObjectId, Types.ObjectId>,
          MedAnnotationModel
      >('MedAnnotation', medAnnotationSchema);
