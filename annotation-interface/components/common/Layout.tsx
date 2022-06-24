import Link from 'next/link';
import { useRouter } from 'next/router';
import { createElement, PropsWithChildren } from 'react';

import { AnnotationFilterContextProvider } from '../../contexts/annotationFilter';
import { BrickFilterContextProvider } from '../../contexts/brickFilter';
import { LanguageContextProvider } from '../../contexts/language';

export type ContextProvider = ({ children }: PropsWithChildren) => JSX.Element;

interface TabDefinition {
    activePaths: RegExp;
    title: string;
    linkPath: string;
    providers: ContextProvider[];
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
        providers: [LanguageContextProvider, AnnotationFilterContextProvider],
    },
    {
        activePaths: /^\/bricks.*$/,
        title: 'Bricks',
        linkPath: '/bricks',
        providers: [LanguageContextProvider, BrickFilterContextProvider],
    },
];

const Layout = ({ children }: PropsWithChildren) => {
    const router = useRouter();
    const activeIndex = tabDefinitions.findIndex((definition) =>
        router.pathname.match(definition.activePaths),
    );
    return (
        <>
            <div className="h-screen fixed px-8 py-16">
                <ul className="space-y-2">
                    {tabDefinitions.map((tabDefinition, index) => (
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
            <div className="max-w-screen-md mx-auto pt-4">
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
