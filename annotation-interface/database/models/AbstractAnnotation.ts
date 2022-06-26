import mongoose, { SchemaValidator, Types } from 'mongoose';

import { BrickUsage } from '../../common/constants';
import { IBaseModel, OptionalId } from '../types';
import TextBrick from './TextBrick';

export interface IAbstractAnnotation<IdT extends OptionalId = undefined>
    extends IBaseModel<IdT> {
    medicationRxCUI: string;
    medicationName: string;
}

const abstractAnnotationSchema = new mongoose.Schema<
    IAbstractAnnotation<Types.ObjectId>
>(
    {
        medicationRxCUI: {
            type: String,
            index: true,
            required: true,
        },
        medicationName: { type: String, required: true },
    },
    { discriminatorKey: 'kind' },
);

abstractAnnotationSchema.pre<
    IAbstractAnnotation<Types.ObjectId> & { kind: string }
>('validate', async function (next) {
    if (!this.kind) next(new Error('Invalid abstract annotation'));
    next();
});

export const annotationBrickValidators = (
    category: BrickUsage,
): SchemaValidator<Types.ObjectId[]>[] => {
    return [
        {
            validator: async (brickIds: Types.ObjectId[] | undefined) => {
                if (!brickIds) return true;
                const bricks = await Promise.all(
                    brickIds.map((id) => TextBrick!.findById(id).lean().exec()),
                );
                return !bricks.find((brick) => brick?.usage !== category);
            },
            message: 'Invalid Brick category',
        },
        {
            validator: (brickIds: Types.ObjectId[] | undefined) =>
                brickIds?.length !== 0,
            message: 'Defined Annotation cannot be empty',
        },
    ];
};

export default !mongoose.models
    ? undefined
    : (mongoose.models.AbstractAnnotation as mongoose.Model<
          IAbstractAnnotation<Types.ObjectId>
      >) ||
      mongoose.model<IAbstractAnnotation<Types.ObjectId>>(
          'AbstractAnnotation',
          abstractAnnotationSchema,
      );
