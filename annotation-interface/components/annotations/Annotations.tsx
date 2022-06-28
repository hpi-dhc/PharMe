import { ServerGuideline, ServerMedication } from '../../common/server-types';
import { IGuidelineAnnotation } from '../../database/models/GuidelineAnnotation';
import { IMedAnnotation } from '../../database/models/MedAnnotation';
import AbstractAnnotation from './AbstractAnnotation';

type Props = {
    refetch: () => void;
    resolvedBricks: Map<string, string>;
    displayContext: string;
};

type MedProps = Props & {
    serverMedication: ServerMedication | undefined;
    annotation: IMedAnnotation<string, string> | null | undefined;
};

export const DrugClassAnnotation = ({
    refetch,
    resolvedBricks,
    displayContext,
    serverMedication,
    annotation,
}: MedProps) => (
    <AbstractAnnotation
        refetch={refetch}
        resolvedBricks={resolvedBricks}
        serverText={serverMedication?.drugclass}
        annotationBrickIds={annotation?.drugclass}
        displayContext={displayContext}
        displayName="patient friendly drug class"
    />
);

export const IndicationAnnotation = ({
    refetch,
    resolvedBricks,
    displayContext,
    serverMedication,
    annotation,
}: MedProps) => (
    <AbstractAnnotation
        refetch={refetch}
        resolvedBricks={resolvedBricks}
        serverText={serverMedication?.indication}
        annotationBrickIds={annotation?.indication}
        displayContext={displayContext}
        displayName="indication"
    />
);

type GuidelineProps = Props & {
    serverGuideline: ServerGuideline | undefined;
    annotation: IGuidelineAnnotation<string, string> | null | undefined;
};

export const ImplicationAnnotation = ({
    refetch,
    resolvedBricks,
    displayContext,
    serverGuideline,
    annotation,
}: GuidelineProps) => (
    <AbstractAnnotation
        refetch={refetch}
        resolvedBricks={resolvedBricks}
        serverText={serverGuideline?.implication}
        annotationBrickIds={annotation?.implication}
        displayContext={displayContext}
        displayName="implication"
    />
);

export const RecommendationAnnotation = ({
    refetch,
    resolvedBricks,
    displayContext,
    serverGuideline,
    annotation,
}: GuidelineProps) => (
    <AbstractAnnotation
        refetch={refetch}
        resolvedBricks={resolvedBricks}
        serverText={serverGuideline?.recommendation}
        annotationBrickIds={annotation?.recommendation}
        displayContext={displayContext}
        displayName="recommendation"
    />
);

// TODO: warning level annotation
