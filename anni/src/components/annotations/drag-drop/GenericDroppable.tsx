import { PropsWithChildren } from 'react';
import { Droppable } from 'react-beautiful-dnd';

interface Props extends React.HTMLAttributes<HTMLDivElement> {
    droppableId: string;
    disableDrop?: boolean | undefined;
    highlightDrag?: boolean | undefined;
    hidePlaceholder?: boolean | undefined;
}

const GenericDroppable = ({
    droppableId,
    disableDrop,
    highlightDrag,
    hidePlaceholder,
    children,
    ...additionalProps
}: PropsWithChildren<Props>) => {
    return (
        <Droppable droppableId={droppableId} isDropDisabled={disableDrop}>
            {(provided, snapshot) => (
                <div
                    ref={provided.innerRef}
                    {...provided.droppableProps}
                    {...{
                        ...additionalProps,
                        className:
                            (additionalProps.className ?? '') +
                            (highlightDrag && snapshot.isDraggingOver
                                ? ' bg-black bg-opacity-50'
                                : ''),
                    }}
                >
                    {children}
                    <div className={hidePlaceholder ? 'hidden' : undefined}>
                        {provided.placeholder}
                    </div>
                </div>
            )}
        </Droppable>
    );
};

export default GenericDroppable;
