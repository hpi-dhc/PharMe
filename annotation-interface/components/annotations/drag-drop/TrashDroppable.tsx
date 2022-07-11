import { TrashIcon } from '@heroicons/react/solid';

import WithIcon from '../../common/WithIcon';
import GenericDroppable from './GenericDroppable';

const TrashDroppable = ({ onClick }: { onClick: () => void }) => (
    <GenericDroppable
        droppableId="trash"
        highlightDrag
        hidePlaceholder
        className="rounded-full"
    >
        <WithIcon
            icon={TrashIcon}
            reverse
            as="button"
            className="py-2 px-4"
            onClick={onClick}
        >
            Clear
        </WithIcon>
    </GenericDroppable>
);

export default TrashDroppable;
