import { FilterIcon } from '@heroicons/react/outline';
import Link from 'next/link';
import { useRouter } from 'next/router';

import { matches } from '../../common/generic-helpers';
import { useSwrFetcher } from '../../common/react-helpers';
import StatusBadge from '../../components/annotations/StatusBadge';
import GenericError from '../../components/common/indicators/GenericError';
import LoadingSpinner from '../../components/common/indicators/LoadingSpinner';
import SelectionPopover from '../../components/common/interaction/SelectionPopover';
import TableRow from '../../components/common/interaction/TableRow';
import { SearchBar } from '../../components/common/interaction/TextField';
import PageHeading from '../../components/common/structure/PageHeading';
import { filterStates, useAnnotationContext } from '../../contexts/annotations';
import { GetAnnotationsReponse } from '../api/annotations';

const Annotations = () => {
    const { curationFilter, setCurationState, searchQuery, setSearchQuery } =
        useAnnotationContext();

    const { data: response, error } =
        useSwrFetcher<GetAnnotationsReponse>('/api/annotations');
    const drugs = response?.data.data.drugs;

    const filteredDrugs = drugs?.filter(
        ({ name, curationState }) =>
            matches(name, searchQuery) &&
            (curationFilter === 'all' ||
                (curationFilter === 'missing' &&
                    curationState.total > curationState.curated) ||
                (curationFilter === 'complete' &&
                    curationState.total === curationState.curated)),
    );

    const router = useRouter();

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
                <SearchBar
                    query={searchQuery}
                    setQuery={setSearchQuery}
                    onEnter={async () => {
                        if (!filteredDrugs?.length) return false;
                        return await router.push(
                            `/annotations/${filteredDrugs[0]._id}`,
                        );
                    }}
                />
                <SelectionPopover
                    label={`Filter`}
                    options={[...filterStates]}
                    selectedOption={curationFilter}
                    onSelect={setCurationState}
                    icon={FilterIcon}
                />
            </div>
            <div>
                {error ? (
                    <GenericError />
                ) : !filteredDrugs ? (
                    <LoadingSpinner />
                ) : (
                    filteredDrugs?.map((drug) => (
                        <TableRow
                            key={drug._id}
                            link={`/annotations/${drug._id}`}
                        >
                            <div className="flex justify-between">
                                <span className="mr-2">{drug.name}</span>
                                <StatusBadge
                                    curationState={drug.curationState}
                                    staged={drug.isStaged}
                                />
                            </div>
                        </TableRow>
                    ))
                )}
            </div>
        </>
    );
};

export default Annotations;
