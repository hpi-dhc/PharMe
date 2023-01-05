import {
    ExclamationIcon,
    PencilAltIcon,
    TrashIcon,
    UploadIcon,
    XIcon,
} from '@heroicons/react/solid';
import axios from 'axios';
import { useRouter } from 'next/router';
import { PropsWithChildren, useState } from 'react';

import {
    AnnotationKey,
    displayNameForAnnotationKey,
} from '../../common/definitions';
import { UpdateAnnotationBody } from '../../pages/api/annotations/[id]';
import WithIcon from '../common/WithIcon';
import PageOverlay from '../common/structure/PageOverlay';

type Props = PropsWithChildren<{
    _id: string;
    _key: AnnotationKey;
    stringValue: string | null;
    value: unknown;
    hasChanges: boolean;
    onClear: () => void;
    isEditable: boolean;
}>;

export const AnnotationMissing = () => (
    <WithIcon icon={ExclamationIcon}>Not set</WithIcon>
);

const AbstractAnnotation = ({
    _id: id,
    _key: key,
    stringValue,
    value,
    hasChanges,
    onClear,
    children,
    isEditable,
}: PropsWithChildren<Props>) => {
    const [editVisible, setEditVisible] = useState(false);
    const router = useRouter();

    const save = async () => {
        const patch: UpdateAnnotationBody = {
            key,
            newValue: value,
        };
        await axios.patch(`/api/annotations/${id}`, patch);
        done();
    };
    const done = async () => {
        if (hasChanges) {
            await router.replace(router.asPath);
        }
        setEditVisible(false);
    };

    return (
        <>
            <div className="space-y-2">
                <div className="flex justify-between">
                    <h2 className="font-bold">
                        {displayNameForAnnotationKey[key]}
                    </h2>
                    <WithIcon
                        as="button"
                        icon={PencilAltIcon}
                        className={
                            isEditable
                                ? undefined
                                : 'opacity-50 line-through cursor-default'
                        }
                        reverse
                        onClick={() => isEditable && setEditVisible(true)}
                    >
                        Edit
                    </WithIcon>
                </div>
                <p>{stringValue ? stringValue : <AnnotationMissing />}</p>
            </div>
            {editVisible && (
                <PageOverlay
                    hide={() => !hasChanges && setEditVisible(false)}
                    heading={displayNameForAnnotationKey[key]}
                >
                    <h2 className="font-bold">Current value</h2>
                    <div className="border border-opacity-40 border-white py-6 px-2 my-4 flex justify-evenly">
                        <p>{stringValue ?? <AnnotationMissing />}</p>
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
                                onClick={onClear}
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
                    <h2 className="font-bold mt-4">Edit</h2>
                    {children}
                </PageOverlay>
            )}
        </>
    );
};
AbstractAnnotation.displayName = 'AbstractAnnotation';

export default AbstractAnnotation;
