import axios from 'axios';
import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { resetServerContext } from 'react-beautiful-dnd';
import { useSWRConfig } from 'swr';

import { useSwrFetcher } from '../../../common/react-helpers';
import { ServerGuideline } from '../../../common/server-types';
import { GuidelineAnnotation } from '../../../components/annotations/Annotations';
import CpicGuidelineBox from '../../../components/annotations/CpicGuidelineBox';
import PageHeading from '../../../components/common/PageHeading';
import dbConnect from '../../../database/helpers/connect';
import {
    findResolvedBricks,
    ResolvedBrick,
} from '../../../database/helpers/resolve-bricks';
import { GetGuidelineDto } from '../../api/annotations/guidelines/[id]';

const GuidelineDetail = ({
    serverId,
    implicationBricks,
    recommendationBricks,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const implicationBrickMap: Map<string, string> = new Map(implicationBricks);
    const recommendationBrickMap: Map<string, string> = new Map(
        recommendationBricks,
    );
    const { mutate } = useSWRConfig();
    const url = `/api/annotations/guidelines/${serverId}`;
    const { data } = useSwrFetcher<GetGuidelineDto>(url, {
        revalidateOnFocus: false,
        revalidateOnReconnect: false,
    });
    const refetch = () => mutate(url);
    const annotation = data?.data.annotation;
    const guideline = data?.data.serverGuideline;
    const displayContext = guideline
        ? `${guideline.medication.name.toLowerCase()} with ${
              guideline.phenotype.geneSymbol.name
          } (${guideline.phenotype.geneResult.name})`
        : '...';
    return (
        <>
            <PageHeading title={`Guideline for ${displayContext}`}>
                View and edit annotations for this guideline, i.e. its
                implication, recommendation and resulting warning level.
            </PageHeading>
            <div className="space-y-4">
                {guideline && <CpicGuidelineBox guideline={guideline} />}
                <GuidelineAnnotation
                    refetch={refetch}
                    resolvedBricks={implicationBrickMap}
                    displayContext={displayContext}
                    annotation={annotation}
                    serverData={guideline}
                    category="implication"
                />
                <GuidelineAnnotation
                    refetch={refetch}
                    resolvedBricks={recommendationBrickMap}
                    displayContext={displayContext}
                    annotation={annotation}
                    serverData={guideline}
                    category="recommendation"
                />
            </div>
        </>
    );
};

export default GuidelineDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<
    GetServerSidePropsResult<{
        serverId: string;
        implicationBricks: ResolvedBrick<string>[];
        recommendationBricks: ResolvedBrick<string>[];
    }>
> => {
    const serverId = context.params?.id as string;
    if (!serverId) return { notFound: true };
    resetServerContext();
    try {
        const response = await axios.get<ServerGuideline>(
            `http://${process.env.AS_API}/guidelines/${serverId}`,
        );
        const guideline = response.data;
        await dbConnect();
        const [implicationBricks, recommendationBricks] = await Promise.all([
            findResolvedBricks(
                { from: 'serverGuideline', with: guideline },
                { usage: 'Implication' },
            ),
            findResolvedBricks(
                { from: 'serverGuideline', with: guideline },
                { usage: 'Recommendation' },
            ),
        ]);
        return {
            props: {
                serverId,
                implicationBricks: implicationBricks.map(([_id, text]) => [
                    _id.toString(),
                    text,
                ]),
                recommendationBricks: recommendationBricks.map(
                    ([_id, text]) => [_id.toString(), text],
                ),
            },
        };
    } catch (error) {
        return { notFound: true };
    }
};
