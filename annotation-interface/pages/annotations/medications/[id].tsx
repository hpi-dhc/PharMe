import axios from 'axios';
import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { resetServerContext } from 'react-beautiful-dnd';
import { useSWRConfig } from 'swr';

import { useSwrFetcher } from '../../../common/react-helpers';
import {
    serverEndpointMeds,
    ServerMedication,
} from '../../../common/server-types';
import { BackToAnnotations } from '../../../components/annotations/AbstractAnnotationOld';
import { MedAnnotation } from '../../../components/annotations/BrickAnnotations';
import PageHeading from '../../../components/common/PageHeading';
import dbConnect from '../../../database/helpers/connect';
import {
    definedResolvedMap,
    ResolvedBrick,
} from '../../../database/helpers/resolve-bricks';
import TextBrick from '../../../database/models/TextBrick';
import { GetMedicationDto } from '../../api/annotations/medications/[id]';

const MedicationDetail = ({
    serverId,
    classBricks,
    indicationBricks,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
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
                <BackToAnnotations />
                <MedAnnotation
                    refetch={refetch}
                    resolvedBricks={definedResolvedMap(classBricks)}
                    displayContext={displayContext}
                    annotation={annotation}
                    serverData={medication}
                    category="drugclass"
                />
                <MedAnnotation
                    refetch={refetch}
                    resolvedBricks={definedResolvedMap(indicationBricks)}
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
            serverEndpointMeds(serverId),
        );
        const medication = response.data;
        await dbConnect();
        const [classBricks, indicationBricks] = await Promise.all([
            TextBrick!.findResolved(
                { from: 'serverMedication', with: medication },
                { usage: 'Drug class' },
            ),
            TextBrick!.findResolved(
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
