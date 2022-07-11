import { pharMeLanguage, SupportedLanguage } from '../../common/constants';
import {
    ServerGuidelineOverview,
    ServerMedication,
} from '../../common/server-types';
import { IGuidelineAnnotation } from '../models/GuidelineAnnotation';
import { IMedAnnotation } from '../models/MedAnnotation';
import { ITextBrick } from '../models/TextBrick';
import { translationsToMap } from './brick-translations';
import { MongooseId, OptionalId } from './types';

export const medicationBrickPlaceholders = ['drug-name'] as const;
export const allBrickPlaceholders = [
    ...medicationBrickPlaceholders,
    'gene-symbol',
    'gene-result',
] as const;
type BrickPlaceholderValues = {
    [Property in typeof allBrickPlaceholders[number]]?: string;
};

export type BrickResolver =
    | { from: 'medAnnotation'; with: IMedAnnotation<MongooseId> }
    | { from: 'serverMedication'; with: ServerMedication }
    | { from: 'guidelineAnnotation'; with: IGuidelineAnnotation<MongooseId> }
    | { from: 'serverGuideline'; with: ServerGuidelineOverview };

const getPlaceholders = ({
    from: type,
    with: resolver,
}: BrickResolver): BrickPlaceholderValues => {
    switch (type) {
        case 'medAnnotation':
            return { 'drug-name': resolver.medicationName };
        case 'serverMedication':
            return { 'drug-name': resolver.name };
        case 'guidelineAnnotation':
            return {
                'drug-name': resolver.medicationName,
                'gene-symbol': resolver.geneSymbol,
                'gene-result': resolver.geneResult,
            };
        case 'serverGuideline':
            return {
                'drug-name': resolver.medication.name,
                'gene-symbol': resolver.phenotype.geneSymbol.name,
                'gene-result': resolver.phenotype.geneResult.name,
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
