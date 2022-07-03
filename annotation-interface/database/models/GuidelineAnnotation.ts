import mongoose, { Types } from 'mongoose';

import { ServerGuidelineOverview } from '../../common/server-types';
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

interface GuidelineAnnotationModel
    extends mongoose.Model<
        IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>
    > {
    findMatching(
        serverGuideline: ServerGuidelineOverview,
    ): ReturnType<typeof findMatching>;
}

const guidelineAnnotationSchema = new mongoose.Schema<
    IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>,
    GuidelineAnnotationModel
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

function findMatching(
    this: GuidelineAnnotationModel,
    serverGuideline: ServerGuidelineOverview,
) {
    return this.findOne({
        medicationRxCUI: serverGuideline.medication.rxcui,
        geneSymbol: serverGuideline.phenotype.geneSymbol.name,
        geneResult: serverGuideline.phenotype.geneResult.name,
    });
}
guidelineAnnotationSchema.static('findMatching', findMatching);

export default !mongoose.models
    ? undefined
    : (mongoose.models.GuidelineAnnotation as GuidelineAnnotationModel) ||
      AbstractAnnotation!.discriminator<
          IGuidelineAnnotation<Types.ObjectId, Types.ObjectId>,
          GuidelineAnnotationModel
      >('GuidelineAnnotation', guidelineAnnotationSchema);
