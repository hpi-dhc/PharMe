import { IGuideline_Any } from '../models/Guideline';
import { CurationState } from './annotations';

export function guidelineCurationState(
    guideline: IGuideline_Any,
): CurationState {
    const annotations = [
        guideline.annotations.implication,
        guideline.annotations.recommendation,
        guideline.annotations.warningLevel,
    ];
    return {
        total: annotations.length,
        curated: annotations.filter((annotation) => !!annotation).length,
    };
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
