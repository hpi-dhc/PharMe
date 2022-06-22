import '../styles/globals.css';
import type { AppProps } from 'next/app';
import Head from 'next/head';

import Layout from '../components/common/Layout';

function AnnotationInterface({ Component, pageProps }: AppProps) {
    return (
        <>
            <Head>
                <title>PharMe: Annotation Interface</title>
            </Head>
            <Layout>
                <Component {...pageProps} />
            </Layout>
        </>
    );
}

export default AnnotationInterface;
