import { XIcon } from '@heroicons/react/outline';
import { PlusIcon } from '@heroicons/react/solid';
import { Draggable } from 'react-beautiful-dnd';

import WithIcon from '../../common/WithIcon';

type Props = {
    ids: Array<string>;
    resolvedBricks: Map<string, string>;
    onClick: (index: number, id: string) => void;
    action: 'add' | 'remove';
};

const DraggableBricks = ({ ids, resolvedBricks, onClick, action }: Props) => (
    <div className="space-y-2">
        {ids.map((id, index) => (
            <Draggable key={id} draggableId={id} index={index}>
                {(provided) => (
                    <div
                        ref={provided.innerRef}
                        {...provided.draggableProps}
                        {...provided.dragHandleProps}
                        className="py-1 px-3 border border-white border-opacity-50 rounded-xl max-w-max"
                    >
                        <WithIcon
                            icon={action === 'add' ? PlusIcon : XIcon}
                            onClick={() => onClick(index, id)}
                            as="button"
                            className="p-1 mr-1 rounded-full hover:bg-black hover:bg-opacity-50"
                        />
                        {resolvedBricks.get(id)!}
                    </div>
                )}
            </Draggable>
        ))}
    </div>
);

export default DraggableBricks;
