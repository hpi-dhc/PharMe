import { IGuideline_Any } from '../models/Guideline';

export function missingGuidelineAnnotations(guideline: IGuideline_Any): number {
    return [
        guideline.annotations.implication,
        guideline.annotations.recommendation,
        guideline.annotations.warningLevel,
    ].filter((annotation) => !annotation).length;
}

export function guidelineDescription(
    guideline: IGuideline_Any,
): Array<{ gene: string; description: string }> {
    return Object.entries(guideline.lookupkey).map(([gene, description]) => {
        return {
            gene,
            description: Array.from(new Set(description)).join('/'),
        };
    });
}
