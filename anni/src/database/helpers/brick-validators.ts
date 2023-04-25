import { SchemaValidator, Types } from 'mongoose';

import { BrickCategory } from '../../common/definitions';
import TextBrick from '../models/TextBrick';

export const brickAnnotationValidators = (
    category: BrickCategory,
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
