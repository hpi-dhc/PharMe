import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';

import { BrickUsage, brickUsages } from '../../common/definitions';
import { useMountEffect } from '../../common/react-helpers';
import BrickForm from '../../components/bricks/BrickForm';
import PlaceholderInfo from '../../components/bricks/PlaceholderInfo';
import FilterTabs from '../../components/common/FilterTabs';
import PageHeading from '../../components/common/PageHeading';
import {
    useBrickFilterContext,
    DisplayCategory,
    displayCategoryForIndex,
    indexForDisplayCategory,
} from '../../contexts/brickFilter';
import dbConnect from '../../database/helpers/connect';
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
                <p>
                    View your Brick or edit it by changing its usage category,
                    its different translations or by deleting it. Hit cancel
                    below to exit without making any changes.
                </p>
                <PlaceholderInfo />
            </PageHeading>
            <FilterTabs
                titles={[...brickUsages]}
                selected={categoryIndex - 1}
                setSelected={(newIndex) => setCategoryIndex(newIndex + 1)}
            ></FilterTabs>
            <BrickForm usage={categoryString as BrickUsage} brick={brick} />
        </>
    );
};

export default EditBrick;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<GetServerSidePropsResult<{ brick: ITextBrick<string> }>> => {
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
