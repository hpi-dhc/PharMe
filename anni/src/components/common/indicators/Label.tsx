import { createElement, ElementType } from 'react';

interface Props<T> extends React.HTMLAttributes<T> {
    as?: ElementType;
    title: string;
    dark?: boolean;
    gray?: boolean;
}

function Label<T>({
    as: parent,
    title,
    dark,
    gray,
    ...additionalProps
}: Props<T>) {
    return createElement(
        parent ?? 'span',
        {
            ...additionalProps,
            className:
                'text-xs px-2 py-0.5 rounded-full whitespace-nowrap align-middle mr-2' +
                    (dark
                        ? ' overflow-clip bg-black bg-opacity-80 text-white '
                        : gray
                        ? ' font-semibold border border-gray-500 border-opacity-20  bg-gray-300 bg-opacity-40 '
                        : ' font-semibold border border-black border-opacity-20 ') +
                    additionalProps.className ?? '',
        },
        title,
    );
}

export default Label;
