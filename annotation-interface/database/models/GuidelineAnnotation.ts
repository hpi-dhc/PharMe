import mongoose, { Types } from 'mongoose';

import { MongooseId, OptionalId } from '../helpers/types';
import AbstractAnnotation, {
    annotationBrickValidators,
    IAbstractAnnotation,
} from './AbstractAnnotation';

export interface IGuidelineAnnotation<
    BrickIdT extends MongooseId,
    IdT extends OptionalId = undefined,
> extends IAbstractAnnotation<IdT> {
    geneSymbol: string;
    geneResult: string;
    recommendation?: BrickIdT[] | undefined;
    implication?: BrickIdT[] | undefined;
}

const guidelineAnnotationSchema = new mongoose.Schema<
    IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>
>({
    geneSymbol: { type: String, required: true, index: true },
    geneResult: { type: String, required: true, index: true },
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
});

guidelineAnnotationSchema.pre<
    IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>
>('validate', function (next) {
    if (!this.recommendation && !this.implication)
        next(new Error('At least one category needs to be defined'));
    next();
});

export default !mongoose.models
    ? undefined
    : (mongoose.models.GuidelineAnnotation as mongoose.Model<
          IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>
      >) ||
      AbstractAnnotation!.discriminator<
          IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>
      >('GuidelineAnnotation', guidelineAnnotationSchema);
