import axios from 'axios';

import { ServerGuideline, ServerMedication } from '../../common/server-types';
import { IGuidelineAnnotation } from '../../database/models/GuidelineAnnotation';
import { IMedAnnotation } from '../../database/models/MedAnnotation';
import AbstractAnnotation from './AbstractAnnotation';

type AbstractProps<
    ST extends ServerMedication | ServerGuideline,
    IT extends ST extends ServerMedication
        ? IMedAnnotation<string, string>
        : IGuidelineAnnotation<string, string>,
> = {
    refetch: () => void;
    resolvedBricks: Map<string, string>;
    displayContext: string;
    serverData: ST | undefined;
    annotation: IT | null | undefined;
    category: keyof (ST | IT);
};

type AnyAnnotationCategory =
    | keyof (ServerMedication | IMedAnnotation<string, string>)
    | keyof (ServerGuideline | IGuidelineAnnotation<string, string>);
const displayName: Map<AnyAnnotationCategory, string> = new Map([
    ['drugclass', 'patient friendly drug class'],
]);

function AbstractAnnotationHelper<
    ST extends ServerMedication | ServerGuideline,
    IT extends ST extends ServerMedication
        ? IMedAnnotation<string, string>
        : IGuidelineAnnotation<string, string>,
>({
    refetch,
    resolvedBricks,
    displayContext,
    serverData,
    annotation,
    category,
    apiEndpoint,
}: AbstractProps<ST, IT> & { apiEndpoint: string }) {
    return (
        <AbstractAnnotation
            refetch={refetch}
            patchApi={async (brickIds, text) => {
                const patch = {
                    annotation: { [category]: brickIds },
                    serverData: { [category]: text },
                };
                await axios.patch(
                    `/api/annotations/${apiEndpoint}/${serverData?.id}`,
                    patch,
                );
            }}
            resolvedBricks={resolvedBricks}
            /* typescript gets confused with how ST and IT are related so we
             * help a little.Using this function is still typesafe though; it
             * wouldn't allow us to use ServerMedication and
             * IGuidelineAnnotation for example. */
            serverText={serverData?.[category] as string | undefined}
            annotationBrickIds={
                annotation?.[category] as string[] | null | undefined
            }
            displayContext={displayContext}
            displayName={
                displayName.get(category as AnyAnnotationCategory) ??
                (category as AnyAnnotationCategory)
            }
        />
    );
}

export const MedAnnotation = (
    props: AbstractProps<ServerMedication, IMedAnnotation<string, string>>,
) => <AbstractAnnotationHelper {...props} apiEndpoint="medications" />;

export const GuidelineAnnotation = (
    props: AbstractProps<ServerGuideline, IGuidelineAnnotation<string, string>>,
) => <AbstractAnnotationHelper {...props} apiEndpoint="guidelines" />;

// TODO: warning level annotation
