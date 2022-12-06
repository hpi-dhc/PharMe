import {
    BrickUsage,
    pharMeLanguage,
    SupportedLanguage,
} from '../../common/definitions';
import { IDrug_Any } from '../models/Drug';
import { IGuideline_Any } from '../models/Guideline';
import { ITextBrick } from '../models/TextBrick';
import { translationsToMap } from './brick-translations';
import { OptionalId } from './types';

const drugBrickPlaceholders = ['drug-name'] as const;
const allBrickPlaceholders = [...drugBrickPlaceholders] as const;
export const placeHoldersForBrick = (category: BrickUsage): string[] => {
    switch (category) {
        case 'Drug class':
        case 'Drug indication':
            return [...drugBrickPlaceholders];
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
    | { from: 'drug'; with: IDrug_Any }
    | {
          from: 'guideline';
          with: { drugName: string; guideline: IGuideline_Any };
      };

const getPlaceholders = ({
    from: type,
    with: resolver,
}: BrickResolver): BrickPlaceholderValues => {
    switch (type) {
        case 'drug':
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

export function resolveStringOrFail<IdT extends OptionalId>(
    resolver: BrickResolver,
    bricks: ITextBrick<IdT>[] | undefined,
    language: SupportedLanguage = pharMeLanguage,
): string {
    if (!bricks) {
        throw new Error('Annotation missing.');
    }
    const resolved = resolveBricks(resolver, bricks, language);
    if (resolved.find(([, text]) => text === null)) {
        throw new Error('Translation missing.');
    }
    return resolved.map(([, text]) => text!).join(' ');
}
