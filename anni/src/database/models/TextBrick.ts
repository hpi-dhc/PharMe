import mongoose, { Types } from 'mongoose';

import {
    brickCategories,
    SupportedLanguage,
    BrickCategory,
    supportedLanguages,
} from '../../common/definitions';
import { translationIsValid } from '../helpers/brick-translations';
import { IBaseDoc, OptionalId } from '../helpers/types';
import { versionedModel } from '../versioning/schema';

export interface ITextBrickTranslation<IdT extends OptionalId = undefined>
    extends IBaseDoc<IdT> {
    language: SupportedLanguage;
    text: string;
}

export interface ITextBrick<IdT extends OptionalId = undefined>
    extends IBaseDoc<IdT> {
    usage: BrickCategory;
    translations: ITextBrickTranslation<IdT>[];
}
export type ITextBrick_DB = ITextBrick<Types.ObjectId>;
export type ITextBrick_Str = ITextBrick<string>;

const { makeModel } = versionedModel<ITextBrick_DB>('TextBrick', {
    usage: {
        type: String,
        enum: brickCategories,
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

// prevent client side from trying to use node module
export default !mongoose.models ? undefined : makeModel();
