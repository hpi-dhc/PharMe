import { PropsWithChildren } from 'react';

const Emphasis = ({ children }: PropsWithChildren) => (
    <span className="italic">{children}</span>
);

export default Emphasis;
