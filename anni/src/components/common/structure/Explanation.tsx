import { PropsWithChildren } from 'react';

const Explanation = ({ children }: PropsWithChildren) => (
    <div className="py-1 pl-4 border-l-4 border-black border-opacity-10 opacity-60">
        {children}
    </div>
);

export default Explanation;
