import { Draggable } from 'react-beautiful-dnd';

type Props = { id: string; index: number; text: string };

const DraggableBrick = ({ id, index, text }: Props) => (
    <Draggable draggableId={id} index={index}>
        {(provided) => (
            <div
                ref={provided.innerRef}
                {...provided.draggableProps}
                {...provided.dragHandleProps}
                className="p-2"
            >
                <p className="py-1 px-3 border border-white border-opacity-50 rounded-xl max-w-max">
                    {text}
                </p>
            </div>
        )}
    </Draggable>
);

export default DraggableBrick;
