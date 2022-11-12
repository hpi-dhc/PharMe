import mongoose, { FilterQuery, Types } from 'mongoose';

import {
    brickUsages,
    SupportedLanguage,
    BrickUsage,
    supportedLanguages,
    pharMeLanguage,
} from '../../common/constants';
import { translationIsValid } from '../helpers/brick-translations';
import {
    BrickResolver,
    resolveBricks,
    ResolvedBrick,
} from '../helpers/resolve-bricks';
import { IBaseModel, OptionalId } from '../helpers/types';

export interface ITextBrickTranslation<IdT extends OptionalId = undefined>
    extends IBaseModel<IdT> {
    language: SupportedLanguage;
    text: string;
}

export interface ITextBrick<IdT extends OptionalId = undefined>
    extends IBaseModel<IdT> {
    usage: BrickUsage;
    translations: ITextBrickTranslation<IdT>[];
}
export type ITextBrick_DB = ITextBrick<Types.ObjectId>;
export type ITextBrick_Str = ITextBrick<string>;

export interface TextBrickModel extends mongoose.Model<ITextBrick_DB> {
    findResolved(
        resolver: BrickResolver,
        filter: FilterQuery<ITextBrick_DB>,
        language?: SupportedLanguage,
    ): Promise<ResolvedBrick<Types.ObjectId>[]>;
}

const textBrickSchema = new mongoose.Schema<ITextBrick_DB>({
    usage: {
        type: String,
        enum: brickUsages,
        required: true,
    },
    translations: {
        type: [
            {
                language: {
                    type: String,
                    enum: supportedLanguages,
                    required: true,
                },
                text: {
                    type: String,
                    required: true,
                },
            },
        ],
        validate: [
            {
                validator: (
                    translations: ITextBrickTranslation<Types.ObjectId>[],
                ) => translations.length > 0,
                message:
                    'TextBricks should be defined in at least one language.',
            },
            {
                validator: (
                    translations: ITextBrickTranslation<Types.ObjectId>[],
                ) =>
                    translations.length ===
                    new Set(translations.map((t) => t.language)).size,
                message: 'Each language should at most have one translation.',
            },
            {
                validator: (
                    translations: ITextBrickTranslation<Types.ObjectId>[],
                ) =>
                    translations.filter((t) => !translationIsValid(t))
                        .length === 0,
                message: 'Each  language should at most have one translation.',
            },
        ],
    },
});

textBrickSchema.static(
    'findResolved',
    async function (
        resolver: BrickResolver,
        filter: FilterQuery<ITextBrick_DB>,
        language?: SupportedLanguage,
    ): Promise<ResolvedBrick<Types.ObjectId>[]> {
        const bricks = await this.find(filter).lean().exec();
        return resolveBricks(resolver, bricks, language ?? pharMeLanguage);
    },
);

// prevent client side from trying to use node module
export default !mongoose.models
    ? undefined
    : (mongoose.models.TextBrick as TextBrickModel) ||
      mongoose.model<ITextBrick<Types.ObjectId>, TextBrickModel>(
          'TextBrick',
          textBrickSchema,
      );
