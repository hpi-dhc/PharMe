import axios from 'axios';
import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { resetServerContext } from 'react-beautiful-dnd';
import { useSWRConfig } from 'swr';

import { useSwrFetcher } from '../../../common/react-helpers';
import { ServerMedication } from '../../../common/server-types';
import { MedAnnotation } from '../../../components/annotations/Annotations';
import PageHeading from '../../../components/common/PageHeading';
import dbConnect from '../../../database/helpers/connect';
import {
    findResolvedBricks,
    ResolvedBrick,
} from '../../../database/helpers/resolve-bricks';
import { GetMedicationDto } from '../../api/annotations/medications/[id]';

const MedicationDetail = ({
    serverId,
    classBricks,
    indicationBricks,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const classBrickMap: Map<string, string> = new Map(classBricks);
    const indicationBrickMap: Map<string, string> = new Map(indicationBricks);
    const { mutate } = useSWRConfig();
    const url = `/api/annotations/medications/${serverId}`;
    const { data } = useSwrFetcher<GetMedicationDto>(url, {
        revalidateOnFocus: false,
        revalidateOnReconnect: false,
    });
    const refetch = () => mutate(url);
    const annotation = data?.data.annotation;
    const medication = data?.data.serverMedication;
    const displayContext = medication ? medication.name : '...';
    return (
        <>
            <PageHeading title={`Drug: ${displayContext}`}>
                View and edit annotations for this drug, i.e. its
                patient-friendly drug class and its indication.
            </PageHeading>
            <div className="space-y-4">
                <MedAnnotation
                    refetch={refetch}
                    resolvedBricks={classBrickMap}
                    displayContext={displayContext}
                    annotation={annotation}
                    serverData={medication}
                    category="drugclass"
                />
                <MedAnnotation
                    refetch={refetch}
                    resolvedBricks={indicationBrickMap}
                    displayContext={displayContext}
                    annotation={annotation}
                    serverData={medication}
                    category="indication"
                />
            </div>
        </>
    );
};

export default MedicationDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<
    GetServerSidePropsResult<{
        serverId: string;
        classBricks: ResolvedBrick<string>[];
        indicationBricks: ResolvedBrick<string>[];
    }>
> => {
    const serverId = context.params?.id as string;
    if (!serverId) return { notFound: true };
    resetServerContext();
    try {
        const response = await axios.get<ServerMedication>(
            `http://${process.env.AS_API}/medications/${serverId}`,
        );
        const medication = response.data;
        await dbConnect();
        const [classBricks, indicationBricks] = await Promise.all([
            findResolvedBricks(
                { from: 'serverMedication', with: medication },
                { usage: 'Drug class' },
            ),
            findResolvedBricks(
                { from: 'serverMedication', with: medication },
                { usage: 'Drug indication' },
            ),
        ]);
        return {
            props: {
                serverId,
                classBricks: classBricks.map(([_id, text]) => [
                    _id.toString(),
                    text,
                ]),
                indicationBricks: indicationBricks.map(([_id, text]) => [
                    _id.toString(),
                    text,
                ]),
            },
        };
    } catch (error) {
        return { notFound: true };
    }
};
