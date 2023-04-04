import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { resetServerContext } from 'react-beautiful-dnd';

import { annotationComponent } from '../../../common/definitions';
import GuidelineBox from '../../../components/annotations/GuidelineBox';
import { useStagingApi } from '../../../components/annotations/StagingToggle';
import TopBar from '../../../components/annotations/TopBar';
import PageHeading from '../../../components/common/structure/PageHeading';
import { useGlobalContext } from '../../../contexts/global';
import dbConnect from '../../../database/helpers/connect';
import { guidelineDescription } from '../../../database/helpers/guideline-data';
import { makeIdsStrings } from '../../../database/helpers/types';
import Drug from '../../../database/models/Drug';
import Guideline, {
    IGuideline_Populated,
} from '../../../database/models/Guideline';
import { ITextBrick_Str } from '../../../database/models/TextBrick';

const GuidelineDetail = ({
    drugName,
    guideline,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const { reviewMode } = useGlobalContext();
    const stagingApi = useStagingApi(guideline._id!);
    const isEditable = !reviewMode && !stagingApi.isStaged;
    return (
        <>
            <PageHeading title={`Guideline for ${drugName}`}>
                {guidelineDescription(guideline).map((phenotype, index) => (
                    <p key={index}>
                        <span className="font-bold mr-2">{phenotype.gene}</span>
                        {phenotype.description}
                    </p>
                ))}
            </PageHeading>
            <div className="space-y-4">
                <TopBar {...stagingApi} />
                <GuidelineBox guideline={guideline.cpicData} />
                {annotationComponent.implication(
                    drugName,
                    guideline,
                    isEditable,
                )}
                {annotationComponent.recommendation(
                    drugName,
                    guideline,
                    isEditable,
                )}
                {annotationComponent.warningLevel(
                    drugName,
                    guideline,
                    isEditable,
                )}
            </div>
        </>
    );
};

export default GuidelineDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<
    GetServerSidePropsResult<{
        drugName: string;
        guideline: IGuideline_Populated;
    }>
> => {
    const drugId = context.params?.did as string;
    const guidelineId = context.params?.gid as string;
    if (!drugId || !guidelineId) return { notFound: true };
    resetServerContext();
    try {
        await dbConnect();
        const drug = await Drug!.findById(drugId).lean().orFail().exec();
        const guideline = await Guideline!
            .findById(guidelineId)
            .populate<{
                'annotations.implication': Array<ITextBrick_Str> | undefined;
                'annotations.recommendation': Array<ITextBrick_Str> | undefined;
            }>(['annotations.implication', 'annotations.recommendation'])
            .lean()
            .orFail()
            .exec();
        return {
            props: {
                drugName: drug.name,
                guideline: makeIdsStrings(guideline) as IGuideline_Populated,
            },
        };
    } catch (error) {
        return { notFound: true };
    }
};
