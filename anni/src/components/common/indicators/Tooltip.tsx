import { InformationCircleIcon } from '@heroicons/react/outline';
import { PropsWithChildren } from 'react';

import WithIcon from '../WithIcon';

type Props = {
    hint: string;
    expandUpwards?: boolean;
};

const Tooltip = ({
    hint,
    expandUpwards,
    children,
}: PropsWithChildren<Props>) => (
    <div className="relative group">
        {children}
        <div
            className={`absolute w-full min-w-min bg-neutral-50 hidden group-hover:block ${
                expandUpwards ? '-translate-y-full -top-2' : ''
            } border border-black border-opacity-10 rounded-md shadow-sm p-2 text-sm text-neutral-700`}
        >
            <WithIcon icon={InformationCircleIcon}>{hint}</WithIcon>
            <div className="absolute top-full left-1/2 -translate-x-1/2 w-0 h-0 border-x-8 border-x-transparent border-t-8 border-t-black border-opacity-10 "></div>
        </div>
    </div>
);

export default Tooltip;
