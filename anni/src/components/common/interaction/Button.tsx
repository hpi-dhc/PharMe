import { AnnotationIcon } from '@heroicons/react/solid';
import { ButtonHTMLAttributes, PropsWithChildren } from 'react';

import WithIcon from '../WithIcon';

interface Props extends ButtonHTMLAttributes<HTMLButtonElement> {
    dark?: boolean;
    icon?: typeof AnnotationIcon;
    reverse?: boolean;
}

const Button = ({
    dark,
    icon,
    reverse,
    children,
    ...additionalProps
}: PropsWithChildren<Props>) => {
    const props = {
        ...additionalProps,
        className: `px-2 py-1 rounded-md whitespace-nowrap text-sm border ${
            dark
                ? 'border-white border-opacity-20 hover:bg-neutral-900'
                : 'border-black border-opacity-20 hover:bg-neutral-100'
        } ${additionalProps.className ?? ''}`,
    };
    return icon ? (
        <WithIcon icon={icon} as="button" reverse={reverse} {...props}>
            {children}
        </WithIcon>
    ) : (
        <button {...props}>{children}</button>
    );
};

export default Button;
