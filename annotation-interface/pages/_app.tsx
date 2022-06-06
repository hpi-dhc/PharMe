import '../styles/globals.css';
import type { AppProps } from 'next/app';
import Head from 'next/head';

function AnnotationInterface({ Component, pageProps }: AppProps) {
    return (
        <>
            <Head>
                <title>PharMe: Annotation Interface</title>
            </Head>
            <div className="max-w-screen-md mx-auto">
                <Component {...pageProps} />
            </div>
        </>
    );
}

export default AnnotationInterface;
