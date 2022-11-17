import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { resetServerContext } from 'react-beautiful-dnd';

import dbConnect from '../../../database/helpers/connect';
import { guidelineDisplayName } from '../../../database/helpers/guideline-data';
import { makeIdsStrings } from '../../../database/helpers/types';
import Guideline, {
    IGuideline_Populated,
} from '../../../database/models/Guideline';
import Medication from '../../../database/models/Medication';

const GuidelineDetail = ({
    drugName,
    guideline,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    console.log(drugName);
    console.log(guideline);
    return (
        <div>
            TODO {drugName}, {guidelineDisplayName(guideline)}
        </div>
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
        const drug = await Medication!.findById(drugId).lean().orFail().exec();
        const guideline = await Guideline!
            .findById(guidelineId)
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
