import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';

import {
    BrickUsage,
    brickUsages,
    DisplayCategory,
    displayCategoryForIndex,
    indexForDisplayCategory,
} from '../../common/constants';
import { useMountEffect } from '../../common/react-helpers';
import BrickForm from '../../components/BrickForm';
import FilterTabs, { DisplayFilterProps } from '../../components/FilterTabs';
import PageHeading from '../../components/PageHeading';
import dbConnect from '../../database/connect';
import TextBrick, { ITextBrick } from '../../database/models/TextBrick';

const EditBrick = ({
    brick,
    display,
}: InferGetServerSidePropsType<typeof getServerSideProps> &
    DisplayFilterProps) => {
    const categoryString: string = displayCategoryForIndex(
        display.categoryIndex,
    );
    useMountEffect(() => {
        if (!(brickUsages as readonly string[]).includes(categoryString)) {
            display.setCategoryIndex(
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
            <FilterTabs
                withLanguagePicker={false}
                withAllOption={false}
                display={display}
            ></FilterTabs>
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
    const result = await TextBrick!.findById(context.params.id).exec();
    if (!result) return { notFound: true };
    const brick = result.toObject();
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
