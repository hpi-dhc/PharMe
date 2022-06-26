import mongoose, { Types } from 'mongoose';

import {
    brickUsages,
    SupportedLanguage,
    BrickUsage,
    supportedLanguages,
} from '../../common/constants';
import { IBaseModel, OptionalId } from '../types';

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

export function translationsToMap<IdT extends OptionalId = undefined>(
    translations: ITextBrickTranslation<IdT>[],
): Map<SupportedLanguage, string> {
    const map = new Map<SupportedLanguage, string>();
    if (translations) {
        translations.forEach((translation) =>
            map.set(translation.language, translation.text),
        );
    }
    return map;
}

export function translationsToArray(
    translations: Map<SupportedLanguage, string>,
): ITextBrickTranslation[] {
    return Array.from(translations.entries()).map(([language, text]) => {
        return { language, text };
    });
}

export function translationIsValid<IdT extends OptionalId = undefined>(
    translation: ITextBrickTranslation<IdT>,
): boolean {
    return translation.text.length > 0;
}

// prevent client side from trying to use node module
export default !mongoose.models
    ? undefined
    : (mongoose.models.TextBrick as mongoose.Model<
          ITextBrick<Types.ObjectId>
      >) ||
      mongoose.model<ITextBrick<Types.ObjectId>>(
          'TextBrick',
          new mongoose.Schema<ITextBrick<Types.ObjectId>>({
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
                          message:
                              'Each language should at most have one translation.',
                      },
                      {
                          validator: (
                              translations: ITextBrickTranslation<Types.ObjectId>[],
                          ) =>
                              translations.filter((t) => !translationIsValid(t))
                                  .length === 0,
                          message:
                              'Each  language should at most have one translation.',
                      },
                  ],
              },
          }),
      );
