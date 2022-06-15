import axios from 'axios';
import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';

import { ServerGuideline } from '../../../common/server-types';
import Annotation from '../../../components/annotations/Annotation';
import CpicGuidelineBox from '../../../components/annotations/CpicGuidelineBox';
import PageHeading from '../../../components/common/PageHeading';

const GuidelineDetail = ({
    guideline,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    return (
        <>
            <PageHeading title={`Guideline`}>
                Use this page to view and edit annotations for{' '}
                {guideline.medication.name.toLowerCase()} with{' '}
                {guideline.phenotype.geneSymbol.name} (
                {guideline.phenotype.geneResult.name}), i.e. its implication,
                recommendation and resulting warning level.
            </PageHeading>
            <div className="space-y-4">
                <CpicGuidelineBox guideline={guideline} />
                <Annotation title="Implication" body={guideline.implication} />
                <Annotation
                    title="Recommendation"
                    body={guideline.recommendation}
                />
                <Annotation
                    title="Warning level"
                    body={guideline.warningLevel}
                />
            </div>
        </>
    );
};

export default GuidelineDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<GetServerSidePropsResult<{ guideline: ServerGuideline }>> => {
    if (!context.params?.id) return { notFound: true };
    try {
        const response = await axios.get<ServerGuideline>(
            `http://${process.env.AS_API}/guidelines/${context.params.id}`,
        );
        const guideline = response.data;
        return { props: { guideline } };
    } catch (error) {
        return { notFound: true };
    }
};
