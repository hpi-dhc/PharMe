import { ChevronRightIcon } from '@heroicons/react/solid';
import Link from 'next/link';
import { Key, PropsWithChildren } from 'react';

import WithIcon from './WithIcon';

interface Props {
    key?: Key;
    link: string;
}

function TableRow({ key, link, children }: PropsWithChildren<Props>) {
    return (
        <Link key={key} href={link}>
            <a className="border-t border-black border-opacity-10 py-3 pl-3 flex justify-between hover:bg-neutral-50">
                <div className="grow">{children}</div>
                <WithIcon icon={ChevronRightIcon} reverse className="px-2" />
            </a>
        </Link>
    );
}

export default TableRow;
