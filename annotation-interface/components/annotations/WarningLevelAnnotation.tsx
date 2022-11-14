import {
    CheckCircleIcon,
    ExclamationIcon,
    TrashIcon,
    UploadIcon,
    XCircleIcon,
    XIcon,
} from '@heroicons/react/solid';
import axios from 'axios';
import { useEffect, useRef, useState } from 'react';

import {
    ServerGuideline,
    WarningLevel,
    warningLevelValues,
} from '../../common/server-types';
import { IGuidelineAnnotation } from '../../database/models/GuidelineAnnotation';
import WithIcon from '../common/WithIcon';
import AbstractAnnotationOld, {
    AbstractAnnotationRef,
    AnnotationMissing,
} from './AbstractAnnotationOld';

type Props = {
    refetch: () => void;
    displayContext: string;
    serverData: ServerGuideline | undefined;
    annotation: IGuidelineAnnotation<string, string> | null | undefined;
};

const iconForLevel: Map<WarningLevel, typeof CheckCircleIcon> = new Map([
    ['ok', CheckCircleIcon],
    ['warning', ExclamationIcon],
    ['danger', XCircleIcon],
]);

const WarningLevelAnnotation = ({
    refetch,
    displayContext,
    serverData,
    annotation,
}: Props) => {
    const annotationRef = useRef<null | AbstractAnnotationRef>(null);
    const [selection, setSelection] = useState<WarningLevel | null>(null);
    useEffect(
        () => setSelection(annotation?.warningLevel ?? null),
        [annotation],
    );

    const save = async () => {
        if (!serverData) return;
        const patch = {
            annotation: { warningLevel: selection },
            serverData: { warningLevel: selection },
        };
        await axios.patch(
            `/api/annotations/guidelines/${serverData.id}`,
            patch,
        );
        done();
    };
    const done = () => {
        annotationRef.current?.hideOverlay();
        refetch();
    };

    return (
        <AbstractAnnotationOld
            serverValue={serverData?.warningLevel}
            hasChanges={serverData?.warningLevel !== selection}
            displayContext={displayContext}
            displayName="warning level"
            ref={annotationRef}
        >
            {!selection && <AnnotationMissing />}
            <div className="border border-opacity-40 border-white py-6 px-2 my-4 flex justify-evenly">
                {warningLevelValues.map((level, index) => (
                    <WithIcon
                        key={index}
                        icon={iconForLevel.get(level)!}
                        as="button"
                        onClick={() => setSelection(level)}
                        className={`py-2 px-4 rounded-full border border-white bg-black ${
                            level === selection
                                ? 'border-opacity-40 bg-opacity-50'
                                : 'border-opacity-0 bg-opacity-0'
                        }`}
                    >
                        {level[0].toUpperCase() + level.slice(1)}
                    </WithIcon>
                ))}
            </div>
            <div className="flex justify-between py-2">
                <WithIcon as="button" icon={XIcon} onClick={done}>
                    Cancel
                </WithIcon>
                <div className="flex space-x-4">
                    <WithIcon
                        as="button"
                        icon={TrashIcon}
                        reverse
                        onClick={() => setSelection(null)}
                    >
                        Clear
                    </WithIcon>
                    <WithIcon
                        as="button"
                        icon={UploadIcon}
                        reverse
                        onClick={save}
                    >
                        Save
                    </WithIcon>
                </div>
            </div>
        </AbstractAnnotationOld>
    );
};

export default WarningLevelAnnotation;
