import mongoose, { Types } from 'mongoose';

import {
    brickUsages,
    SupportedLanguage,
    BrickUsage,
    supportedLanguages,
} from '../../common/constants';

export interface ITextBrickTranslation {
    _id?: Types.ObjectId;
    language: SupportedLanguage;
    text: string;
}

export interface ITextBrick {
    _id?: Types.ObjectId;
    usage: BrickUsage;
    translations: ITextBrickTranslation[];
}

// prevent client side from trying to use node module
export default !mongoose.models
    ? undefined
    : (mongoose.models.TextBrick as mongoose.Model<ITextBrick>) ||
      mongoose.model<ITextBrick>(
          'TextBrick',
          new mongoose.Schema<ITextBrick>({
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
                              validate: {
                                  validator: (text: string) => text.length > 0,
                                  message:
                                      'TextBrick texts should not be empty',
                              },
                          },
                      },
                  ],
                  validate: [
                      {
                          validator: (translations: ITextBrickTranslation[]) =>
                              translations.length > 0,
                          message:
                              'TextBricks should be defined in at least one language.',
                      },
                      {
                          validator: (translations: ITextBrickTranslation[]) =>
                              translations.length ===
                              new Set(translations.map((t) => t.language)).size,
                          message:
                              'Each  language should at most have one translation.',
                      },
                  ],
              },
          }),
      );
