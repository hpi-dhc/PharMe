import BrickAnnotation from '../components/annotations/BrickAnnotation';
import {
    IGuideline_Any,
    IGuideline_Populated,
} from '../database/models/Guideline';
import {
    IMedication_Any,
    IMedication_Populated,
} from '../database/models/Medication';

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

export type DrugAnnotationKey = keyof IMedication_Any['annotations'];
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

export const annotationComponent: Record<
    DrugAnnotationKey,
    (drug: IMedication_Populated) => JSX.Element
> &
    Record<
        GuidelineAnnotationKey,
        (guideline: IGuideline_Populated) => JSX.Element
    > = {
    drugclass: (drug) => _drugAnnotation(drug, 'drugclass'),
    indication: (drug) => _drugAnnotation(drug, 'indication'),
    implication: (guideline) => _guidelineAnnotation(guideline, 'implication'),
    recommendation: (guideline) =>
        _guidelineAnnotation(guideline, 'recommendation'),
    warningLevel: (guideline) =>
        _guidelineAnnotation(guideline, 'warningLevel'),
};

const _drugAnnotation = (
    drug: IMedication_Populated,
    key: DrugAnnotationKey,
): JSX.Element => (
    <BrickAnnotation
        _id={drug._id}
        annotation={drug.annotations[key]}
        key={key}
    />
);

const _guidelineAnnotation = (
    guideline: IGuideline_Populated,
    key: GuidelineAnnotationKey,
): JSX.Element => {
    switch (key) {
        case 'warningLevel':
            // TODO: new warning level annotation
            return <div>todo</div>;
        default:
            return (
                <BrickAnnotation
                    _id={guideline._id}
                    annotation={guideline.annotations[key]}
                    key={key}
                />
            );
    }
};
