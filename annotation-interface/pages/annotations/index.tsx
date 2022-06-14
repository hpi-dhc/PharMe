import { Tab } from '@headlessui/react';
import axios from 'axios';
import { GetServerSidePropsResult, InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import {
    ServerGuidelineOverview,
    ServerMedication,
} from '../../common/server-types';
import FilterTabs from '../../components/common/FilterTabs';
import Label from '../../components/common/Label';
import PageHeading from '../../components/common/PageHeading';
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

const Annotations = ({
    medications,
    guidelines,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const { curationState, setCurationState, categoryIndex, setCategoryIndex } =
        useAnnotationFilterContext();
    const medicationsWithLabels = medications.map((medication) => {
        const labels = getMissingLabels(medication, [
            { name: 'indication', display: 'Indication' },
            { name: 'drugclass', display: 'Drug class' },
        ]);
        return { medication, labels };
    });
    const guidelinesWithLabels = guidelines.map((guideline) => {
        const labels = getMissingLabels(guideline, [
            { name: 'implication', display: 'Implication' },
            { name: 'recommendation', display: 'Recommendation' },
            { name: 'warningLevel', display: 'Warning level' },
        ]);
        return { guideline, labels };
    });

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
                    {filteredElements(medicationsWithLabels, curationState).map(
                        (item) => (
                            <p
                                key={item.medication.id}
                                className="border-t border-black border-opacity-10 py-3 pl-3"
                            >
                                <span className="mr-2">
                                    {item.medication.name}
                                </span>
                                {item.labels}
                            </p>
                        ),
                    )}
                </Tab.Panel>
                <Tab.Panel className="space-y-2">
                    {filteredElements(guidelinesWithLabels, curationState).map(
                        (item) => (
                            <div
                                key={item.guideline.id}
                                className="border-t border-black border-opacity-10 py-3 pl-3"
                            >
                                <p className="mr-2">
                                    {item.guideline.phenotype.geneSymbol.name}{' '}
                                    and {item.guideline.medication.name}:{' '}
                                    {item.guideline.phenotype.geneResult.name}
                                </p>
                                {item.labels}
                            </div>
                        ),
                    )}
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
            axios.get<ServerMedication[]>(
                `http://${process.env.AS_API}/medications`,
                { params: { withGuidelines: true } },
            ),
            axios.get<ServerGuidelineOverview[]>(
                `http://${process.env.AS_API}/guidelines`,
            ),
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
