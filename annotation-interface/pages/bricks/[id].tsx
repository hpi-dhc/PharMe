import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';

import { BrickUsage, brickUsages } from '../../common/constants';
import { useMountEffect } from '../../common/react-helpers';
import BrickForm from '../../components/BrickForm';
import FilterTabs from '../../components/FilterTabs';
import PageHeading from '../../components/PageHeading';
import {
    useBrickFilterContext,
    DisplayCategory,
    displayCategoryForIndex,
    indexForDisplayCategory,
} from '../../contexts/brickFilter';
import dbConnect from '../../database/connect';
import TextBrick, { ITextBrick } from '../../database/models/TextBrick';

const EditBrick = ({
    brick,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const { categoryIndex, setCategoryIndex } = useBrickFilterContext();
    const categoryString: string = displayCategoryForIndex(categoryIndex);
    useMountEffect(() => {
        if (!(brickUsages as readonly string[]).includes(categoryString)) {
            setCategoryIndex(
                indexForDisplayCategory(brick.usage as DisplayCategory),
            );
        }
    });
    return (
        <>
            <PageHeading title="Edit Brick">
                View your Brick or edit it by changing its usage category, its
                different translations or by deleting it. Hit cancel below to
                exit without making any changes.
            </PageHeading>
            <FilterTabs withAllOption={false}></FilterTabs>
            <BrickForm usage={categoryString as BrickUsage} brick={brick} />
        </>
    );
};

export default EditBrick;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<GetServerSidePropsResult<{ brick: ITextBrick }>> => {
    if (!context.params?.id) return { notFound: true };
    await dbConnect();
    const brick = await TextBrick!.findById(context.params.id).lean().exec();
    if (!brick) return { notFound: true };
    return {
        props: {
            brick: {
                ...brick,
                _id: brick._id!.toString(),
                translations: brick.translations.map((translation) => {
                    return { ...translation, _id: translation._id!.toString() };
                }),
            },
        },
    };
};
