import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { useRouter } from 'next/router';
import { resetServerContext } from 'react-beautiful-dnd';

import { BackToAnnotations } from '../../components/annotations/AbstractAnnotation';
import PageHeading from '../../components/common/PageHeading';
import dbConnect from '../../database/helpers/connect';
import { makeIdsStrings } from '../../database/helpers/types';
import { IGuideline_DB } from '../../database/models/Guideline';
import Medication, { IMedication_Str } from '../../database/models/Medication';

const DrugDetail = ({
    drug,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const router = useRouter();
    const mutate = () => {
        router.replace(router.asPath);
    };
    return (
        <>
            <PageHeading title={`Drug: ${drug.name}`}>
                View and edit annotations for this drug, i.e. its
                patient-friendly drug class and its indication.
            </PageHeading>
            <div className="space-y-4">
                <BackToAnnotations />
            </div>
        </>
    );
};

export default DrugDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<
    GetServerSidePropsResult<{
        drug: IMedication_Str;
    }>
> => {
    const id = context.params?.id as string;
    if (!id) return { notFound: true };
    resetServerContext();
    try {
        await dbConnect();
        const drug = await Medication!
            .findById(id)
            .populate<{ guidelines: IGuideline_DB }>('guidelines')
            .orFail()
            .exec();
        return { props: { drug: makeIdsStrings(drug) as IMedication_Str } };
    } catch (error) {
        return { notFound: true };
    }
};
