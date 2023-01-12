import { AnnotationIcon } from '@heroicons/react/solid';
import { createElement, ElementType, PropsWithChildren } from 'react';

interface Props<T> extends React.HTMLAttributes<T> {
    as?: ElementType;
    icon: typeof AnnotationIcon;
    reverse?: boolean;
}

function WithIcon<T>({
    as: parent,
    icon,
    reverse,
    children,
    ...additionalProps
}: PropsWithChildren<Props<T>>) {
    const iconElement = createElement(icon, {
        className: `h-5 w-5 shrink-0 ${
            children && (reverse ? 'ml-2' : 'mr-2')
        }`,
    });
    return createElement(
        parent ?? 'span',
        {
            ...additionalProps,
            className: `inline-flex ${additionalProps.className ?? ''}`,
        },
        <>
            {!reverse && iconElement}
            {children}
            {reverse && iconElement}
        </>,
    );
}

export default WithIcon;
