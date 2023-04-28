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
        function descriptionString(descriptionParts: [string]): string {
            return Array.from(new Set(descriptionParts)).join('/');
        }
        const phenotypeDescriptionString = descriptionString(
            guideline.phenotypes[gene],
        );
        const lookupkeyDescriptionString = descriptionString(
            guideline.lookupkey[gene],
        );
        const description =
            phenotypeDescriptionString != lookupkeyDescriptionString
                ? `${phenotypeDescriptionString} (${lookupkeyDescriptionString})`
                : phenotypeDescriptionString;
        return {
            gene,
            description,
        };
    });
}
