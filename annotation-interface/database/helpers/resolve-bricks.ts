import {
    BrickUsage,
    pharMeLanguage,
    SupportedLanguage,
} from '../../common/definitions';
import { IGuideline_Any } from '../models/Guideline';
import { IMedication_Any } from '../models/Medication';
import { ITextBrick } from '../models/TextBrick';
import { translationsToMap } from './brick-translations';
import { OptionalId } from './types';

const medicationBrickPlaceholders = ['drug-name'] as const;
const allBrickPlaceholders = [...medicationBrickPlaceholders] as const;
export const placeHoldersForBrick = (category: BrickUsage): string[] => {
    switch (category) {
        case 'Drug class':
        case 'Drug indication':
            return [...medicationBrickPlaceholders];
        case 'Implication':
        case 'Recommendation':
            return [...allBrickPlaceholders];
        default:
            return [];
    }
};
type BrickPlaceholderValues = {
    [Property in typeof allBrickPlaceholders[number]]?: string;
};

export type BrickResolver =
    | { from: 'medication'; with: IMedication_Any }
    | {
          from: 'guideline';
          with: { drugName: string; guideline: IGuideline_Any };
      };

const getPlaceholders = ({
    from: type,
    with: resolver,
}: BrickResolver): BrickPlaceholderValues => {
    switch (type) {
        case 'medication':
            return { 'drug-name': resolver.name };
        case 'guideline':
            return { 'drug-name': resolver.drugName };
    }
};

export type ResolvedBrick<IdT extends OptionalId> = [
    _id: IdT,
    text: string | null,
];

export function resolveBricks<IdT extends OptionalId>(
    resolver: BrickResolver,
    bricks: ITextBrick<IdT>[],
    language: SupportedLanguage = pharMeLanguage,
): ResolvedBrick<IdT>[] {
    const placeholders = getPlaceholders(resolver);
    const resolved = bricks.map(({ _id, translations }) => {
        let text = translationsToMap(translations).get(language);
        if (text) {
            Object.entries(placeholders).forEach(([placeholder, replace]) => {
                text = text!.replaceAll(`#${placeholder}`, replace);
            });
        }
        return [_id, text ?? null] as ResolvedBrick<IdT>;
    });

    return resolved;
}
