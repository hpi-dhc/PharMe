import '../styles/globals.css';
import type { AppProps } from 'next/app';
import Head from 'next/head';
import { useState } from 'react';

import { SupportedLanguage, supportedLanguages } from '../common/constants';
import NavBar from '../components/NavBar';

function AnnotationInterface({ Component, pageProps }: AppProps) {
    const [displayLanguage, setDisplayLanguage] = useState<SupportedLanguage>(
        supportedLanguages[0],
    );
    const [displayCategoryIndex, setDisplayCategoryIndex] = useState(0);

    return (
        <>
            <Head>
                <title>PharMe: Annotation Interface</title>
            </Head>
            <NavBar />
            <div className="max-w-screen-md mx-auto pt-4">
                <Component
                    {...pageProps}
                    display={{
                        categoryIndex: displayCategoryIndex,
                        setCategoryIndex: setDisplayCategoryIndex,
                        language: displayLanguage,
                        setLanguage: setDisplayLanguage,
                    }}
                />
            </div>
        </>
    );
}

export default AnnotationInterface;
