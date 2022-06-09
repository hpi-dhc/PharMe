import Link from 'next/link';

import PageHeading from '../components/PageHeading';

const Annotations = () => {
    return (
        <PageHeading title="Annotations">
            Annotations make up data that is manually curated for PharMe, i.e.
            implication and recommendation for a drug-phenotype pair and
            indication and a patient-friendly drug-class for a drug. Annotations
            are built using{' '}
            <Link href="/bricks">
                <a className="italic underline">bricks</a>
            </Link>
            .
        </PageHeading>
    );
};

export default Annotations;
