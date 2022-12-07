import Link from 'next/link';
import { useRouter } from 'next/router';
import { createElement, PropsWithChildren } from 'react';

import { AnnotationFilterContextProvider } from '../../../contexts/annotations';
import { BrickFilterContextProvider } from '../../../contexts/brickFilter';
import { useGlobalContext } from '../../../contexts/global';
import DisplayLanguagePicker from '../interaction/DisplayLanguagePicker';

export type ContextProvider = ({ children }: PropsWithChildren) => JSX.Element;

interface TabDefinition {
    activePaths: RegExp;
    title: string;
    linkPath: string;
    providers: ContextProvider[];
    hideInReview?: boolean;
}

export function ResolvedProviders({
    providers,
    children,
}: PropsWithChildren<{ providers: ContextProvider[] }>) {
    if (providers.length === 0) return <>{children}</>;
    return createElement(
        providers[0],
        null,
        <ResolvedProviders providers={providers.slice(1)}>
            {children}
        </ResolvedProviders>,
    );
}

const tabDefinitions: TabDefinition[] = [
    { activePaths: /^\/$/, title: 'Home', linkPath: '/', providers: [] },
    {
        activePaths: /^\/annotations.*$/,
        title: 'Annotations',
        linkPath: '/annotations',
        providers: [AnnotationFilterContextProvider],
    },
    {
        activePaths: /^\/bricks.*$/,
        title: 'Bricks',
        linkPath: '/bricks',
        providers: [BrickFilterContextProvider],
        hideInReview: true,
    },
];

const Layout = ({ children }: PropsWithChildren) => {
    const router = useRouter();
    const activeIndex = tabDefinitions.findIndex((definition) =>
        router.pathname.match(definition.activePaths),
    );
    const { reviewMode } = useGlobalContext();
    return (
        <>
            <div className="h-screen fixed px-8 py-16 flex flex-col justify-between">
                <div>
                    <ul className="space-y-2">
                        {tabDefinitions
                            .filter((def) => !reviewMode || !def.hideInReview)
                            .map((tabDefinition, index) => (
                                <li
                                    key={index}
                                    className={`font-medium ${
                                        index === activeIndex && 'underline'
                                    }`}
                                >
                                    <Link href={tabDefinition.linkPath}>
                                        <a>{tabDefinition.title}</a>
                                    </Link>
                                </li>
                            ))}
                    </ul>
                </div>
                <DisplayLanguagePicker />
            </div>
            <div className="max-w-screen-md mx-auto pt-4 pb-48">
                {activeIndex === -1 ? (
                    children
                ) : (
                    <ResolvedProviders
                        providers={tabDefinitions[activeIndex].providers}
                    >
                        {children}
                    </ResolvedProviders>
                )}
            </div>
        </>
    );
};

export default Layout;
