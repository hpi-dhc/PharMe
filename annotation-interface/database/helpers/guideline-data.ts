import { IGuideline_Any } from '../models/Guideline';

export function missingGuidelineAnnotations(guideline: IGuideline_Any): number {
    return [
        guideline.annotations.implication,
        guideline.annotations.recommendation,
        guideline.annotations.warningLevel,
    ].filter((annotation) => !annotation).length;
}

export function guidelineDisplayName(guideline: IGuideline_Any): string {
    return Object.entries(guideline.lookupkey)
        .map(([gene, phenotypes]) => `${gene}: ${phenotypes.join('/')}`)
        .join('\n');
}
