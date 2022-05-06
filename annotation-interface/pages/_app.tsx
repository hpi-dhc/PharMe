import '../styles/globals.css';
import type { AppProps } from 'next/app';

function AnnotationInterface({ Component, pageProps }: AppProps) {
    return <Component {...pageProps} />;
}

export default AnnotationInterface;
