import Link from 'next/link';

import PageHeading from '../components/common/structure/PageHeading';

const Home = () => {
    return (
        <>
            <PageHeading title="PharMe's Annotation Interface">
                Welcome to the curator&apos;s interface to PharMe&apos;s
                user-agnostic data. PharMe uses{' '}
                <span className="italic">external data</span> from{' '}
                <a className="underline" href="https://cpicpgx.org">
                    CPIC
                </a>{' '}
                as well as <span className="italic">internal data</span> defined
                by{' '}
                <Link href="/annotations">
                    <a className="underline">Annotations</a>
                </Link>
                .
            </PageHeading>
        </>
    );
};

export default Home;
