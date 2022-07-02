import {
    PencilAltIcon,
    ExclamationIcon,
    XIcon,
    UploadIcon,
} from '@heroicons/react/solid';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { DragDropContext, DropResult } from 'react-beautiful-dnd';

import PageOverlay from '../common/PageOverlay';
import WithIcon from '../common/WithIcon';
import DraggableBrick from './drag-drop/DraggableBrick';
import GenericDroppable from './drag-drop/GenericDroppable';
import TrashDroppable from './drag-drop/TrashDroppable';

type AbstractProps = {
    refetch: () => void;
    patchApi: (brickIds: string[] | null, text: string | null) => Promise<void>;
    resolvedBricks: Map<string, string>;
    serverText: string | null | undefined;
    annotationBrickIds: string[] | null | undefined;
    displayContext: string;
    displayName: string;
};

const Missing = () => <WithIcon icon={ExclamationIcon}>Not set</WithIcon>;

const AbstractAnnotation = ({
    refetch,
    patchApi,
    resolvedBricks,
    serverText,
    annotationBrickIds,
    displayContext,
    displayName,
}: AbstractProps) => {
    const [editVisible, setEditVisible] = useState(false);
    const [usedBrickIds, setUsedBrickIds] = useState<string[] | null>(null);
    useEffect(
        () => setUsedBrickIds(annotationBrickIds ?? null),
        [annotationBrickIds],
    );

    const annotationText =
        usedBrickIds && usedBrickIds.length > 0
            ? usedBrickIds?.map((id) => resolvedBricks.get(id)!)?.join(' ')
            : null;
    const unusedBrickIds = [...resolvedBricks.keys()].filter(
        (id) => !usedBrickIds?.includes(id),
    );

    const onDragEnd = (result: DropResult) => {
        if (!result.destination) return;
        const selected = Array.from(usedBrickIds ?? []);
        switch (result.source.droppableId) {
            case 'used':
                selected.splice(result.source.index, 1);
                if (result.destination.droppableId === 'trash') break;
                selected.splice(
                    result.destination.index,
                    0,
                    result.draggableId,
                );
                break;
            case 'unused':
                if (result.destination?.droppableId !== 'used') return;
                selected.splice(
                    result.destination.index,
                    0,
                    result.draggableId,
                );
                break;
        }
        setUsedBrickIds(selected.length > 0 ? selected : null);
    };

    const save = async () => {
        await patchApi(usedBrickIds, annotationText);
        done();
    };

    const done = () => {
        setEditVisible(false);
        refetch();
    };

    const AnnotationEditor = () => (
        <DragDropContext onDragEnd={onDragEnd}>
            <GenericDroppable
                droppableId="used"
                highlightDrag
                className="border border-opacity-40 border-white py-6 px-2 my-4"
            >
                {usedBrickIds?.map((id, index) => (
                    <DraggableBrick
                        key={id}
                        id={id}
                        index={index}
                        text={resolvedBricks.get(id)!}
                    />
                ))}
            </GenericDroppable>

            <div className="flex justify-between">
                <WithIcon
                    as="button"
                    icon={XIcon}
                    onClick={done}
                    className="py-2"
                >
                    Cancel
                </WithIcon>
                <div className="flex space-x-4">
                    {usedBrickIds && usedBrickIds.length > 0 && (
                        <TrashDroppable onClick={() => setUsedBrickIds(null)} />
                    )}
                    <WithIcon
                        as="button"
                        icon={UploadIcon}
                        reverse
                        onClick={save}
                        className="py-2"
                    >
                        Save
                    </WithIcon>
                </div>
            </div>
            <h2 className="font-bold my-4">Defined Bricks</h2>
            <GenericDroppable droppableId="unused" disableDrop>
                {unusedBrickIds.map((id, index) => (
                    <DraggableBrick
                        key={id}
                        id={id}
                        index={index}
                        text={resolvedBricks.get(id)!}
                    />
                ))}
            </GenericDroppable>
        </DragDropContext>
    );

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
                <p>{serverText ? serverText : <Missing />}</p>
            </div>
            {editVisible && (
                <PageOverlay
                    hide={() => serverText === annotationText && done()}
                    heading={`Edit the ${displayName} for ${displayContext}`}
                >
                    <p>{annotationText ?? <Missing />}</p>
                    {resolvedBricks.size > 0 ? (
                        <AnnotationEditor />
                    ) : (
                        <p className="my-6">
                            Looks like there aren&apos;t any defined Bricks for
                            this type of annotation. Click{' '}
                            <Link href="/bricks/new">
                                <a className="underline">here</a>
                            </Link>{' '}
                            to create a new Brick!
                        </p>
                    )}
                </PageOverlay>
            )}
        </>
    );
};

export default AbstractAnnotation;
