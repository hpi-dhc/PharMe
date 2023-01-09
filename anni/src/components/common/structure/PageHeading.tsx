import { PropsWithChildren } from 'react';

import Explanation from '../text/Explanation';

const PageHeading = ({
    title,
    children,
}: PropsWithChildren<{ title: string }>) => (
    <div className="my-6">
        <h1 className="text-4xl font-extrabold my-4">{title}</h1>
        {children && <Explanation>{children}</Explanation>}
    </div>
);

export default PageHeading;
