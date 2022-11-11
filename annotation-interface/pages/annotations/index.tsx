import { ChevronRightIcon, FilterIcon } from '@heroicons/react/outline';
import { GetServerSidePropsResult, InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import Label from '../../components/common/Label';
import PageHeading from '../../components/common/PageHeading';
import SearchBar from '../../components/common/SearchBar';
import SelectionPopover from '../../components/common/SelectionPopover';
import WithIcon from '../../components/common/WithIcon';
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
                    <Link
                        key={drug.id}
                        href={`/annotations/medications/${drug.id}`}
                    >
                        <a className="border-t border-black border-opacity-10 py-3 pl-3 block flex justify-between hover:bg-neutral-50">
                            <span className="mr-2">{drug.name}</span>
                            <WithIcon
                                icon={ChevronRightIcon}
                                reverse
                                className="pr-2"
                            >
                                <span>
                                    <Label title={`${drug.badge} missing`} />
                                </span>
                            </WithIcon>
                        </a>
                    </Link>
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
