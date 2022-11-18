import { ChevronRightIcon } from '@heroicons/react/solid';
import Link from 'next/link';
import { PropsWithChildren } from 'react';

import WithIcon from './WithIcon';

interface Props {
    link: string;
}

function TableRow({ link, children }: PropsWithChildren<Props>) {
    return (
        <Link href={link}>
            <a className="border-t border-black border-opacity-10 py-3 pl-3 flex justify-between hover:bg-neutral-100">
                <div className="grow">{children}</div>
                <WithIcon icon={ChevronRightIcon} reverse className="px-2" />
            </a>
        </Link>
    );
}

export default TableRow;
