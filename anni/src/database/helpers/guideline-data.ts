import { CurationState } from './annotations';
import { IGuideline_Any } from '../models/Guideline';

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
    return Object.keys(guideline.lookupkey).map((gene) => {
        const lookupkeys = guideline.lookupkey[gene];
        let description = Array.from(new Set(lookupkeys)).join('/');
        if ('phenotypes' in guideline && gene in guideline.phenotypes) {
            const phenotypes = Array.from(
                new Set(guideline.phenotypes[gene]),
            ).join('/');
            if (phenotypes != description) {
                description = `${phenotypes} (${description})`;
            }
        }

        return {
            gene,
            description,
        };
    });
}
