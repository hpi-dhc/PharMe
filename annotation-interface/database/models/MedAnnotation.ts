import mongoose, { Types } from 'mongoose';

import { MongooseId, OptionalId } from '../types';
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

const medAnnotationSchema = new mongoose.Schema<
    IMedAnnotation<Types.ObjectId, Types.ObjectId>
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

export default !mongoose.models
    ? undefined
    : (mongoose.models.MedAnnotation as mongoose.Model<
          IMedAnnotation<Types.ObjectId, Types.ObjectId>
      >) ||
      AbstractAnnotation!.discriminator<
          IMedAnnotation<Types.ObjectId, Types.ObjectId>
      >('MedAnnotation', medAnnotationSchema);
