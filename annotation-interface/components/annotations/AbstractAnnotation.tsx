import {
    ChevronLeftIcon,
    ExclamationIcon,
    PencilAltIcon,
} from '@heroicons/react/solid';
import Link from 'next/link';
import {
    forwardRef,
    PropsWithChildren,
    useImperativeHandle,
    useState,
} from 'react';

import PageOverlay from '../common/PageOverlay';
import WithIcon from '../common/WithIcon';

export type AbstractAnnotationRef = {
    hideOverlay: () => void;
};
type Props = PropsWithChildren<{
    serverValue: string | null | undefined;
    hasChanges: boolean;
    displayContext: string;
    displayName: string;
}>;

export const AnnotationMissing = () => (
    <WithIcon icon={ExclamationIcon}>Not set</WithIcon>
);

export const BackToAnnotations = () => (
    <Link href="/annotations">
        <a className="underline">
            <WithIcon icon={ChevronLeftIcon}>Back</WithIcon>
        </a>
    </Link>
);

const AbstractAnnotation = forwardRef<AbstractAnnotationRef, Props>(
    (
        { serverValue, hasChanges, displayContext, displayName, children },
        ref,
    ) => {
        const [editVisible, setEditVisible] = useState(false);
        useImperativeHandle(ref, () => ({
            hideOverlay: () => setEditVisible(false),
        }));

        return (
            <>
                <div className="space-y-2">
                    <div className="flex justify-between">
                        <h2 className="font-bold">
                            {displayName.charAt(0).toUpperCase() +
                                displayName.slice(1)}
                        </h2>
                        <WithIcon
                            as="button"
                            icon={PencilAltIcon}
                            reverse
                            onClick={() => setEditVisible(true)}
                        >
                            Edit
                        </WithIcon>
                    </div>
                    <p>{serverValue ? serverValue : <AnnotationMissing />}</p>
                </div>
                {editVisible && (
                    <PageOverlay
                        hide={() => !hasChanges && setEditVisible(false)}
                        heading={`Edit the ${displayName} for ${displayContext}`}
                    >
                        {children}
                    </PageOverlay>
                )}
            </>
        );
    },
);
AbstractAnnotation.displayName = 'AbstractAnnotation';

export default AbstractAnnotation;
