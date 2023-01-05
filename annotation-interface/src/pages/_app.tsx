import '../styles/globals.css';
import type { AppProps } from 'next/app';
import Head from 'next/head';

import Layout from '../components/common/structure/Layout';
import { GlobalContextProvider } from '../contexts/global';

function AnnotationInterface({ Component, pageProps }: AppProps) {
    return (
        <>
            <Head>
                <title>PharMe: Annotation Interface</title>
            </Head>
            <GlobalContextProvider>
                <Layout>
                    <Component {...pageProps} />
                </Layout>
            </GlobalContextProvider>
        </>
    );
}

export default AnnotationInterface;
