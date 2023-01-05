import { PropsWithChildren } from 'react';

const PageHeading = ({
    title,
    children,
}: PropsWithChildren<{ title: string }>) => (
    <div className="my-6">
        <h1 className="text-4xl font-extrabold my-4">{title}</h1>
        {children && (
            <div className="py-1 pl-4 border-l-4 border-black border-opacity-10 opacity-60">
                {children}
            </div>
        )}
    </div>
);

export default PageHeading;
