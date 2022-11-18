import { Dispatch, SetStateAction, useState } from 'react';
import { DragDropContext, DropResult } from 'react-beautiful-dnd';

import { matches } from '../../common/generic-helpers';
import SearchBar from '../common/interaction/SearchBar';
import DraggableBricks from './drag-drop/DraggableBrick';
import GenericDroppable from './drag-drop/GenericDroppable';

type Props = {
    allBricks: Map<string, string>;
    usedIds: Set<string> | undefined;
    setUsedIds: Dispatch<SetStateAction<Set<string> | undefined>>;
};

const BrickAnnotationEditor = ({ allBricks, usedIds, setUsedIds }: Props) => {
    const [query, setQuery] = useState('');

    const unusedIds = new Set<string>();
    allBricks.forEach((_, id) => {
        if (usedIds?.has(id)) return;
        if (!query || matches(allBricks.get(id)!, query)) unusedIds.add(id);
    });

    const removeOrInsert = (index: number, newValue: string | null = null) => {
        if (newValue) usedIds?.delete(newValue);
        const used = Array.from(usedIds ?? []);
        if (newValue) {
            used.splice(index, 0, newValue);
        } else {
            used.splice(index, 1);
        }
        setUsedIds(used.length > 0 ? new Set(used) : undefined);
    };

    const onDragEnd = (result: DropResult) => {
        if (!result.destination) return;
        removeOrInsert(result.destination.index, result.draggableId);
    };

    return (
        <DragDropContext onDragEnd={onDragEnd}>
            <div className="space-y-4">
                <GenericDroppable
                    droppableId="used"
                    highlightDrag
                    className="border border-opacity-40 border-white py-6 px-2 my-4"
                >
                    <DraggableBricks
                        ids={Array.from(usedIds ?? [])}
                        resolvedBricks={allBricks}
                        onClick={(index) => removeOrInsert(index)}
                        action="remove"
                    />
                </GenericDroppable>
                <SearchBar
                    query={query}
                    setQuery={setQuery}
                    placeholder="Search for Bricks"
                    dark
                    onEnter={async () => {
                        const first = unusedIds.values().next()?.value;
                        if (first) removeOrInsert(usedIds?.size ?? 0, first);
                        return true;
                    }}
                />
                <GenericDroppable droppableId="unused" disableDrop>
                    <DraggableBricks
                        ids={Array.from(unusedIds ?? [])}
                        resolvedBricks={allBricks}
                        onClick={(_, id) =>
                            removeOrInsert(usedIds?.size ?? 0, id)
                        }
                        action="add"
                    />
                </GenericDroppable>
            </div>
        </DragDropContext>
    );
};

export default BrickAnnotationEditor;
