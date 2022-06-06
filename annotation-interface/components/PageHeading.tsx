import { ReactNode } from 'react';

const PageHeading = ({ children }: { children: ReactNode }) => (
    <h1 className="text-4xl my-6 font-extrabold">{children}</h1>
);

export default PageHeading;
