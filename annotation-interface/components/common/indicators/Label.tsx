import { createElement, ElementType } from 'react';

interface Props<T> extends React.HTMLAttributes<T> {
    as?: ElementType;
    title: string;
    dark?: boolean;
}

function Label<T>({ as: parent, title, dark, ...additionalProps }: Props<T>) {
    return createElement(
        parent ?? 'span',
        {
            ...additionalProps,
            className:
                'text-xs px-2 py-0.5 rounded-full whitespace-nowrap align-middle mr-2' +
                    (dark
                        ? ' overflow-clip bg-black bg-opacity-80 text-white '
                        : ' font-semibold border border-black border-opacity-20 ') +
                    additionalProps.className ?? '',
        },
        title,
    );
}

export default Label;
