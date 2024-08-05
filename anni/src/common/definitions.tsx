import BrandNamesAnnotation from '../components/annotations/BrandNamesAnnotation';
import BrickAnnotation from '../components/annotations/BrickAnnotation';
import WarningLevelAnnotation from '../components/annotations/WarningLevelAnnotation';
import { IDrug_Any, IDrug_Populated } from '../database/models/Drug';
import {
    IGuideline_Any,
    IGuideline_Populated,
} from '../database/models/Guideline';

export const supportedLanguages = ['English', 'German'] as const;
export type SupportedLanguage = (typeof supportedLanguages)[number];
export const pharMeLanguage: SupportedLanguage = 'English';

export const brickCategories = [
    'Drug class',
    'Drug indication',
    'Implication',
    'Recommendation',
] as const;
export type BrickCategory = (typeof brickCategories)[number];

export const warningLevelValues = ['green', 'yellow', 'red', 'none'] as const;
export type WarningLevel = (typeof warningLevelValues)[number];

export type DrugAnnotationKey = keyof IDrug_Any['annotations'];
export type GuidelineAnnotationKey = keyof IGuideline_Any['annotations'];
export type AnnotationKey = DrugAnnotationKey | GuidelineAnnotationKey;

export const brickCategoryForAnnotationKey: {
    [k in AnnotationKey]: (typeof brickCategories)[number] | null;
} = {
    indication: 'Drug indication',
    drugclass: 'Drug class',
    brandNames: null,
    implication: 'Implication',
    recommendation: 'Recommendation',
    warningLevel: null,
} as const;

export const displayNameForAnnotationKey: {
    [k in AnnotationKey]: string;
} = {
    indication: 'Drug indication',
    drugclass: 'Patient-friendly drug class',
    brandNames: 'Brand names',
    implication: 'Implication',
    recommendation: 'Recommendation',
    warningLevel: 'Warning level',
} as const;

export const annotationComponent: Record<
    DrugAnnotationKey,
    (drug: IDrug_Populated, isEditable: boolean | undefined) => JSX.Element
> &
    Record<
        GuidelineAnnotationKey,
        (
            drugName: string,
            guideline: IGuideline_Populated,
            isEditable: boolean | undefined,
        ) => JSX.Element
    > = {
    drugclass: (drug, isEditable) =>
        _drugAnnotation(drug, isEditable, 'drugclass'),
    indication: (drug, isEditable) =>
        _drugAnnotation(drug, isEditable, 'indication'),
    brandNames: (drug, isEditable) =>
        _drugAnnotation(drug, isEditable, 'brandNames'),
    implication: (drugName, guideline, isEditable) =>
        _guidelineAnnotation(drugName, guideline, isEditable, 'implication'),
    recommendation: (drugName, guideline, isEditable) =>
        _guidelineAnnotation(drugName, guideline, isEditable, 'recommendation'),
    warningLevel: (drugName, guideline, isEditable) =>
        _guidelineAnnotation(drugName, guideline, isEditable, 'warningLevel'),
};

const _drugAnnotation = (
    drug: IDrug_Populated,
    isEditable: boolean | undefined,
    key: DrugAnnotationKey,
): JSX.Element => {
    switch (key) {
        case 'brandNames':
            return (
                <BrandNamesAnnotation drug={drug} isEditable={!!isEditable} />
            );
        default:
            return (
                <BrickAnnotation
                    _id={drug._id!}
                    _key={key}
                    annotation={drug.annotations[key]}
                    brickResolver={{ from: 'drug', with: drug }}
                    isEditable={!!isEditable}
                />
            );
    }
};

const _guidelineAnnotation = (
    drugName: string,
    guideline: IGuideline_Populated,
    isEditable: boolean | undefined,
    key: GuidelineAnnotationKey,
): JSX.Element => {
    switch (key) {
        case 'warningLevel':
            return (
                <WarningLevelAnnotation
                    guideline={guideline}
                    isEditable={!!isEditable}
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
                    isEditable={!!isEditable}
                />
            );
    }
};
