import { FilterIcon } from '@heroicons/react/outline';
import Link from 'next/link';

import { useSwrFetcher } from '../../common/react-helpers';
import GenericError from '../../components/common/GenericError';
import Label from '../../components/common/Label';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import PageHeading from '../../components/common/PageHeading';
import SearchBar from '../../components/common/SearchBar';
import SelectionPopover from '../../components/common/SelectionPopover';
import TableRow from '../../components/common/TableRow';
import { filterStates, useAnnotationContext } from '../../contexts/annotations';
import { GetAnnotationsReponse } from '../api/annotations';

const matches = (test: string, query: string) => {
    test = test.toLowerCase();
    return (
        query
            .toLowerCase()
            .split(/\s+/)
            .filter((word) => !test.includes(word)).length === 0
    );
};

const Annotations = () => {
    const { curationState, setCurationState, searchQuery, setSearchQuery } =
        useAnnotationContext();

    const { data: response, error } =
        useSwrFetcher<GetAnnotationsReponse>('/api/annotations');
    const drugs = response?.data.data.drugs;

    const filteredDrugs = drugs?.filter(
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
                {error ? (
                    <GenericError />
                ) : !filteredDrugs ? (
                    <LoadingSpinner />
                ) : (
                    filteredDrugs?.map((drug) => (
                        <TableRow
                            key={drug.id}
                            link={`/annotations/${drug.id}`}
                        >
                            <div className="flex justify-between">
                                <span className="mr-2">{drug.name}</span>
                                <span>
                                    <Label title={`${drug.badge} missing`} />
                                </span>
                            </div>
                        </TableRow>
                    ))
                )}
            </div>
        </>
    );
};

export default Annotations;
