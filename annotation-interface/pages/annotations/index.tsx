import { FilterIcon } from '@heroicons/react/outline';
import { GetServerSidePropsResult, InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import Label from '../../components/common/Label';
import PageHeading from '../../components/common/PageHeading';
import SearchBar from '../../components/common/SearchBar';
import SelectionPopover from '../../components/common/SelectionPopover';
import TableRow from '../../components/common/TableRow';
import {
    filterStates,
    useAnnotationFilterContext,
} from '../../contexts/annotationFilter';
import Medication from '../../database/models/Medication';

const matches = (test: string, query: string) => {
    test = test.toLowerCase();
    return (
        query
            .toLowerCase()
            .split(/\s+/)
            .filter((word) => !test.includes(word)).length === 0
    );
};

const Annotations = ({
    drugs,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const { curationState, setCurationState, searchQuery, setSearchQuery } =
        useAnnotationFilterContext();

    const filteredDrugs = drugs.filter(
        ({ name, badge }) =>
            matches(name, searchQuery) &&
            (curationState === 'all' ||
                (curationState === 'missing' && badge) ||
                (curationState === 'fully curated' && !badge)),
    );

    return (
        <>
            <PageHeading title="Annotations">
                Annotations make up data that is manually curated for PharMe,
                i.e. implication and recommendation for a drug-phenotype pair
                and indication and a patient-friendly drug-class for a drug.
                Annotations are built using{' '}
                <Link href="/bricks">
                    <a className="italic underline">bricks</a>
                </Link>
                .
            </PageHeading>
            <div className="flex mb-6 space-x-2">
                <SearchBar query={searchQuery} setQuery={setSearchQuery} />
                <SelectionPopover
                    label={`Filter`}
                    options={[...filterStates]}
                    selectedOption={curationState}
                    onSelect={setCurationState}
                    icon={FilterIcon}
                />
            </div>
            <div>
                {filteredDrugs.map((drug) => (
                    <TableRow
                        key={drug.id}
                        link={`/annotations/medications/${drug.id}`}
                    >
                        <div className="flex justify-between">
                            <span className="mr-2">{drug.name}</span>
                            <span>
                                <Label title={`${drug.badge} missing`} />
                            </span>
                        </div>
                    </TableRow>
                ))}
            </div>
        </>
    );
};

export default Annotations;

export const getServerSideProps = async (): Promise<
    GetServerSidePropsResult<{
        drugs: Array<{ id: string; name: string; badge: number }>;
    }>
> => {
    try {
        const drugs = await Medication!.find({}).orFail().exec();
        const badges = await Promise.all(
            drugs.map((drug) => drug.missingAnnotations()),
        );
        return {
            props: {
                drugs: drugs.map((drug, index) => {
                    return {
                        id: drug._id!.toString(),
                        name: drug.name,
                        badge: badges[index],
                    };
                }),
            },
        };
    } catch (error) {
        return { notFound: true };
    }
};
