import React, { PropsWithChildren } from 'react';

interface Props extends React.HTMLAttributes<HTMLDivElement> {
    hide: () => void;
    heading: string;
    explanation: string | undefined;
}

const PageOverlay = ({
    hide,
    heading,
    explanation,
    children,
    ...additionalProps
}: PropsWithChildren<Props>) => {
    return (
        /* extra div to prevent tailwind's spacing from
         * assigning margins to fixed overlay */
        <div>
            <div
                className="z-10 fixed top-0 left-0 w-full h-full bg-black bg-opacity-80 text-white text-opacity-80 backdrop-blur-sm"
                onClick={() => hide()}
            >
                <div
                    className="max-w-screen-md min-h-screen m-auto py-20 space-y-6"
                    onClick={(e) => e.stopPropagation()}
                >
                    <h2 className="text-2xl font-bold">{heading}</h2>
                    {explanation && <p>{explanation}</p>}
                    <div {...additionalProps}>{children}</div>
                </div>
            </div>
        </div>
    );
};

PageOverlay.defaultProps = {
    explanation: undefined,
};

export default PageOverlay;
