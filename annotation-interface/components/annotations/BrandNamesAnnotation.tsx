import { PlusIcon } from '@heroicons/react/solid';
import { useState } from 'react';
import { DragDropContext, DropResult } from 'react-beautiful-dnd';

import { IDrug_Populated } from '../../database/models/Drug';
import TextField from '../common/interaction/TextField';
import AbstractAnnotation from './AbstractAnnotation';
import DraggableBricks from './drag-drop/DraggableBrick';
import GenericDroppable from './drag-drop/GenericDroppable';

type Props = {
    drug: IDrug_Populated;
    isEditable: boolean;
};

const BrandNamesAnnotation = ({ drug, isEditable }: Props) => {
    const [names, setNames] = useState(drug.annotations.brandNames ?? null);
    const [editingName, setEditingName] = useState('');

    const onDragEnd = (result: DropResult) => {
        if (!result.destination || !names) return;
        const currentNames = Array.from(names);
        currentNames.splice(result.source.index, 1);
        currentNames.splice(
            result.destination.index,
            0,
            names[parseInt(result.draggableId)],
        );
        setNames(currentNames);
    };

    return (
        <AbstractAnnotation
            _id={drug._id!}
            _key="brandNames"
            stringValue={names?.join(', ') ?? null}
            value={names}
            hasChanges={
                JSON.stringify(drug.annotations.brandNames) !==
                JSON.stringify(names)
            }
            onClear={() => setNames(null)}
            isEditable={isEditable}
        >
            <div className="space-y-4">
                <DragDropContext onDragEnd={onDragEnd}>
                    <GenericDroppable
                        droppableId="used"
                        highlightDrag
                        className="border border-opacity-40 border-white py-6 px-2 my-4"
                    >
                        {names && (
                            <DraggableBricks
                                ids={[...names.keys()].map((key) =>
                                    key.toString(),
                                )}
                                resolvedBricks={
                                    new Map(
                                        names.map((name, index) => [
                                            index.toString(),
                                            name,
                                        ]),
                                    )
                                }
                                onClick={(index) => {
                                    const currentNames = Array.from(
                                        names ?? [],
                                    );
                                    currentNames.splice(index, 1);
                                    setNames(
                                        currentNames.length > 0
                                            ? currentNames
                                            : null,
                                    );
                                }}
                                action="remove"
                            />
                        )}
                    </GenericDroppable>
                </DragDropContext>
                <p>Add a new brand Name</p>
                <TextField
                    query={editingName}
                    setQuery={setEditingName}
                    dark
                    icon={PlusIcon}
                    onEnter={async () => {
                        if (!editingName) return false;
                        setNames([...(names ?? []), editingName]);
                        return true;
                    }}
                />
            </div>
        </AbstractAnnotation>
    );
};

export default BrandNamesAnnotation;
