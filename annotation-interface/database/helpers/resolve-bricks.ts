import {
    BrickUsage,
    pharMeLanguage,
    SupportedLanguage,
} from '../../common/definitions';
import {
    ServerGuidelineOverview,
    ServerMedication,
} from '../../common/server-types';
import { IGuideline_Any } from '../models/Guideline';
import { IGuidelineAnnotation } from '../models/GuidelineAnnotation';
import { IMedAnnotation } from '../models/MedAnnotation';
import { IMedication_Any } from '../models/Medication';
import { ITextBrick } from '../models/TextBrick';
import { translationsToMap } from './brick-translations';
import { MongooseId, OptionalId } from './types';

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
          with: { medication: IMedication_Any; guideline: IGuideline_Any };
      }
    | { from: 'medAnnotation'; with: IMedAnnotation<MongooseId> }
    | { from: 'serverMedication'; with: ServerMedication }
    | { from: 'guidelineAnnotation'; with: IGuidelineAnnotation<MongooseId> }
    | { from: 'serverGuideline'; with: ServerGuidelineOverview };

const getPlaceholders = ({
    from: type,
    with: resolver,
}: BrickResolver): BrickPlaceholderValues => {
    switch (type) {
        case 'medication':
            return { 'drug-name': resolver.name };
        case 'guideline':
            return {
                'drug-name': resolver.medication.name,
            };
        case 'medAnnotation':
            return { 'drug-name': resolver.medicationName };
        case 'serverMedication':
            return { 'drug-name': resolver.name };
        case 'guidelineAnnotation':
            return {
                'drug-name': resolver.medicationName,
            };
        case 'serverGuideline':
            return {
                'drug-name': resolver.medication.name,
            };
    }
};

export type ResolvedBrick<IdT extends OptionalId> = [
    _id: IdT,
    text: string | undefined,
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
        return [_id, text] as ResolvedBrick<IdT>;
    });

    return resolved;
}

export function definedResolvedMap<IdT extends MongooseId>(
    bricks: ResolvedBrick<IdT>[],
): Map<string, string> {
    return new Map(
        bricks.filter(([, text]) => text !== undefined) as [string, string][],
    );
}
