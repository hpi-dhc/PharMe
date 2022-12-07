import BrickAnnotation from '../components/annotations/BrickAnnotation';
import WarningLevelAnnotation from '../components/annotations/WarningLevelAnnotation';
import { IDrug_Any, IDrug_Populated } from '../database/models/Drug';
import {
    IGuideline_Any,
    IGuideline_Populated,
} from '../database/models/Guideline';

export const supportedLanguages = ['English', 'German'] as const;
export type SupportedLanguage = typeof supportedLanguages[number];
export const pharMeLanguage: SupportedLanguage = 'English';

export const brickUsages = [
    'Drug class',
    'Drug indication',
    'Implication',
    'Recommendation',
] as const;
export type BrickUsage = typeof brickUsages[number];

export const warningLevelValues = ['green', 'yellow', 'red'] as const;
export type WarningLevel = typeof warningLevelValues[number];

export type DrugAnnotationKey = keyof IDrug_Any['annotations'];
export type GuidelineAnnotationKey = keyof IGuideline_Any['annotations'];
export type AnnotationKey = DrugAnnotationKey | GuidelineAnnotationKey;

export const brickCategoryForAnnotationKey: {
    [k in AnnotationKey]: typeof brickUsages[number] | null;
} = {
    indication: 'Drug indication',
    drugclass: 'Drug class',
    implication: 'Implication',
    recommendation: 'Recommendation',
    warningLevel: null,
} as const;

export const displayNameForAnnotationKey: {
    [k in AnnotationKey]: string;
} = {
    indication: 'Drug indication',
    drugclass: 'Patient-friendly drug class',
    implication: 'Implication',
    recommendation: 'Recommendation',
    warningLevel: 'Warning level',
} as const;

export const annotationComponent: Record<
    DrugAnnotationKey,
    (drug: IDrug_Populated, isStaged: boolean | undefined) => JSX.Element
> &
    Record<
        GuidelineAnnotationKey,
        (
            drugName: string,
            guideline: IGuideline_Populated,
            isStaged: boolean | undefined,
        ) => JSX.Element
    > = {
    drugclass: (drug, isStaged) => _drugAnnotation(drug, isStaged, 'drugclass'),
    indication: (drug, isStaged) =>
        _drugAnnotation(drug, isStaged, 'indication'),
    implication: (drugName, guideline, isStaged) =>
        _guidelineAnnotation(drugName, guideline, isStaged, 'implication'),
    recommendation: (drugName, guideline, isStaged) =>
        _guidelineAnnotation(drugName, guideline, isStaged, 'recommendation'),
    warningLevel: (drugName, guideline, isStaged) =>
        _guidelineAnnotation(drugName, guideline, isStaged, 'warningLevel'),
};

const _drugAnnotation = (
    drug: IDrug_Populated,
    isStaged: boolean | undefined,
    key: DrugAnnotationKey,
): JSX.Element => (
    <BrickAnnotation
        _id={drug._id!}
        _key={key}
        annotation={drug.annotations[key]}
        brickResolver={{ from: 'drug', with: drug }}
        isEditable={!isStaged}
    />
);

const _guidelineAnnotation = (
    drugName: string,
    guideline: IGuideline_Populated,
    isStaged: boolean | undefined,
    key: GuidelineAnnotationKey,
): JSX.Element => {
    switch (key) {
        case 'warningLevel':
            return (
                <WarningLevelAnnotation
                    guideline={guideline}
                    isEditable={!isStaged}
                />
            );
        default:
            return (
                <BrickAnnotation
                    _id={guideline._id!}
                    _key={key}
                    annotation={guideline.annotations[key]}
                    brickResolver={{
                        from: 'guideline',
                        with: { drugName, guideline },
                    }}
                    isEditable={!isStaged}
                />
            );
    }
};
