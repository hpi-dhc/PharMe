import axios from 'axios';
import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';

import { ServerMedication } from '../../../common/server-types';
import Annotation from '../../../components/annotations/Annotation';
import PageHeading from '../../../components/common/PageHeading';

const MedicationDetail = ({
    medication,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    return (
        <>
            <PageHeading title={`Drug: ${medication.name}`}>
                Use this page to view and edit annotations for{' '}
                {medication.name.toLowerCase()}, i.e. its patient-friendly drug
                class and its indication.
            </PageHeading>
            <div className="space-y-4">
                <Annotation
                    title="Patient-friendly drug class"
                    body={medication.drugclass}
                />
                <Annotation title="Indication" body={medication.indication} />
            </div>
        </>
    );
};

export default MedicationDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<GetServerSidePropsResult<{ medication: ServerMedication }>> => {
    if (!context.params?.id) return { notFound: true };
    try {
        const response = await axios.get<ServerMedication>(
            `http://${process.env.AS_API}/medications/${context.params.id}`,
        );
        const medication = response.data;
        return { props: { medication } };
    } catch (error) {
        return { notFound: true };
    }
};
