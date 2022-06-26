import { SupportedLanguage } from '../../common/constants';
import { ITextBrickTranslation } from '../models/TextBrick';
import { OptionalId } from './types';

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
