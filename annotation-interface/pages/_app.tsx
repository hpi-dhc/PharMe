import '../styles/globals.css';
import type { AppProps } from 'next/app';
import Head from 'next/head';

import NavBar from '../components/NavBar';

function AnnotationInterface({ Component, pageProps }: AppProps) {
    return (
        <>
            <Head>
                <title>PharMe: Annotation Interface</title>
            </Head>
            <NavBar />
            <div className="max-w-screen-md mx-auto pt-4">
                <Component {...pageProps} />
            </div>
        </>
    );
}

export default AnnotationInterface;
