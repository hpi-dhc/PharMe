import { createElement, ElementType } from 'react';

interface Props<T> extends React.HTMLAttributes<T> {
    as?: ElementType;
    title: string;
}

function Label<T>({ as: parent, title, ...additionalProps }: Props<T>) {
    return createElement(
        parent ?? 'span',
        {
            className:
                'border border-black border-opacity-20 text-xs px-2 rounded-full whitespace-nowrap font-semibold align-text-top mr-2',
            ...additionalProps,
        },
        title,
    );
}

export default Label;
