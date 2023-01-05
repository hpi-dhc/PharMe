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
            stringValue={
                names === null
                    ? null
                    : names.length > 0
                    ? names.join(', ')
                    : '{No brand names}'
            }
            value={names}
            hasChanges={
                JSON.stringify(drug.annotations.brandNames) !==
                JSON.stringify(names)
            }
            onClear={() => setNames(null)}
            isEditable={isEditable}
        >
            <div className="space-y-4 py-4">
                <p className="py-1 pl-4 border-l-4 border-white border-opacity-50 opacity-70 font-light">
                    Add brand names commonly used with patients using the text
                    field below and pressing return, or check the box to
                    communicate that this drug has no relevant brand names.
                </p>
                <DragDropContext onDragEnd={onDragEnd}>
                    <GenericDroppable
                        droppableId="used"
                        highlightDrag
                        className="border border-opacity-40 border-white py-6 px-2 my-4"
                    >
                        {names && names?.length > 0 ? (
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
                        ) : (
                            <div className="px-4">
                                <input
                                    className="opacity-80"
                                    type="checkbox"
                                    checked={names?.length === 0}
                                    onChange={() => {
                                        setNames(names === null ? [] : null);
                                    }}
                                />
                                <label htmlFor="checkbox" className="pl-2">
                                    This drug has no relevant brand names.
                                </label>
                            </div>
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
