import { Tab } from '@headlessui/react';
import axios from 'axios';
import { GetServerSidePropsResult, InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import {
    serverEndpointGuidelines,
    serverEndpointMeds,
    ServerGuidelineOverview,
    ServerMedication,
} from '../../common/server-types';
import FilterTabs from '../../components/common/FilterTabs';
import Label from '../../components/common/Label';
import PageHeading from '../../components/common/PageHeading';
import SearchBar from '../../components/common/SearchBar';
import SelectionPopover from '../../components/common/SelectionPopover';
import {
    FilterState,
    filterStates,
    useAnnotationFilterContext,
} from '../../contexts/annotationFilter';

function getMissingLabels<T>(
    data: T,
    properties: { name: keyof T; display: string }[],
) {
    return properties
        .filter(({ name }) => !data[name])
        .map(({ display }, index) => (
            <Label key={index} title={`${display} missing`} />
        ));
}

function filteredElements<T extends { labels: JSX.Element[] }>(
    elements: T[],
    filter: FilterState,
) {
    return elements.filter(
        ({ labels }) =>
            filter === 'all' ||
            (filter === 'missing' && labels.length) ||
            (filter === 'curated' && !labels.length),
    );
}

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
    medications,
    guidelines,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const {
        curationState,
        setCurationState,
        categoryIndex,
        setCategoryIndex,
        searchQuery,
        setSearchQuery,
    } = useAnnotationFilterContext();

    const medicationsWithLabels = filteredElements(
        medications
            .filter(({ name }) => matches(name, searchQuery))
            .map((medication) => {
                const labels = getMissingLabels(medication, [
                    { name: 'indication', display: 'Indication' },
                    { name: 'drugclass', display: 'Drug class' },
                ]);
                return { medication, labels };
            }),
        curationState,
    );
    const guidelinesWithLabels = filteredElements(
        guidelines
            .filter((guideline) =>
                matches(
                    guideline.medication.name +
                        guideline.phenotype.geneSymbol.name +
                        guideline.phenotype.geneResult.name,
                    searchQuery,
                ),
            )
            .map((guideline) => {
                const labels = getMissingLabels(guideline, [
                    { name: 'implication', display: 'Implication' },
                    { name: 'recommendation', display: 'Recommendation' },
                    { name: 'warningLevel', display: 'Warning level' },
                ]);
                return { guideline, labels };
            }),
        curationState,
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
            <SearchBar query={searchQuery} setQuery={setSearchQuery} />
            <FilterTabs
                titles={['Drugs', 'Guidelines']}
                selected={categoryIndex}
                setSelected={setCategoryIndex}
                accessory={
                    <SelectionPopover
                        label={`Show ${curationState}`}
                        options={[...filterStates]}
                        selectedOption={curationState}
                        onSelect={setCurationState}
                    />
                }
            >
                <Tab.Panel>
                    {medicationsWithLabels.map((item) => (
                        <p
                            key={item.medication.id}
                            className="border-t border-black border-opacity-10 py-3 pl-3"
                        >
                            <Link
                                href={`/annotations/medications/${item.medication.id}`}
                            >
                                <a className="mr-2">{item.medication.name}</a>
                            </Link>
                            {item.labels}
                        </p>
                    ))}
                </Tab.Panel>
                <Tab.Panel className="space-y-2">
                    {guidelinesWithLabels.map((item) => (
                        <div
                            key={item.guideline.id}
                            className="border-t border-black border-opacity-10 py-3 pl-3"
                        >
                            <p className="mr-2">
                                <Link
                                    href={`/annotations/guidelines/${item.guideline.id}`}
                                >
                                    <a className="mr-2">
                                        {
                                            item.guideline.phenotype.geneSymbol
                                                .name
                                        }{' '}
                                        and {item.guideline.medication.name}:{' '}
                                        {
                                            item.guideline.phenotype.geneResult
                                                .name
                                        }
                                    </a>
                                </Link>
                            </p>
                            {item.labels}
                        </div>
                    ))}
                </Tab.Panel>
            </FilterTabs>
        </>
    );
};

export default Annotations;

export const getServerSideProps = async (): Promise<
    GetServerSidePropsResult<{
        medications: ServerMedication[];
        guidelines: ServerGuidelineOverview[];
    }>
> => {
    try {
        const [medicationResponse, guidelineResponse] = await Promise.all([
            axios.get<ServerMedication[]>(serverEndpointMeds(), {
                params: { withGuidelines: true },
            }),
            axios.get<ServerGuidelineOverview[]>(serverEndpointGuidelines()),
        ]);
        return {
            props: {
                medications: medicationResponse.data,
                guidelines: guidelineResponse.data,
            },
        };
    } catch (error) {
        return { notFound: true };
    }
};
