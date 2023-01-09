import Link from 'next/link';

import PageHeading from '../components/common/structure/PageHeading';
import Emphasis from '../components/common/text/Emphasis';

const Home = () => {
    return (
        <div className="space-y-4">
            <PageHeading title="PharMe's Annotation Interface">
                Welcome to the curator&apos;s interface to PharMe&apos;s
                user-agnostic data: the Annotation Interface aka.{' '}
                <Emphasis>Anni</Emphasis>! PharMe uses{' '}
                <Emphasis>external data</Emphasis> from{' '}
                <a className="underline" href="https://cpicpgx.org">
                    CPIC
                </a>{' '}
                and supplements it with patient-oriented{' '}
                <Emphasis>internal data</Emphasis>. This internal data is
                defined using Anni and referred to as{' '}
                <Link href="/annotations">
                    <a className="underline">Annotations</a>
                </Link>
                .
            </PageHeading>
        </div>
    );
};

export default Home;
