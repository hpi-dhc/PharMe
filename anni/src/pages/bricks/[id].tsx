import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';

import { BrickCategory, brickCategories } from '../../common/definitions';
import { useMountEffect, useSwrFetcher } from '../../common/react-helpers';
import BrickForm from '../../components/bricks/BrickForm';
import BrickUsageList from '../../components/bricks/BrickUsage';
import PlaceholderInfo from '../../components/bricks/PlaceholderInfo';
import FilterTabs from '../../components/common/structure/FilterTabs';
import PageHeading from '../../components/common/structure/PageHeading';
import Explanation from '../../components/common/text/Explanation';
import {
    useBrickFilterContext,
    DisplayCategory,
    displayCategoryForIndex,
    indexForDisplayCategory,
} from '../../contexts/brickFilter';
import dbConnect from '../../database/helpers/connect';
import TextBrick, { ITextBrick } from '../../database/models/TextBrick';
import { GetBrickUsageReponse } from '../api/bricks/[id]';

const EditBrick = ({
    brick,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const { categoryIndex, setCategoryIndex } = useBrickFilterContext();
    const categoryString: string = displayCategoryForIndex(categoryIndex);
    useMountEffect(() => {
        if (!(brickCategories as readonly string[]).includes(categoryString)) {
            setCategoryIndex(
                indexForDisplayCategory(brick.usage as DisplayCategory),
            );
        }
    });

    const { data: usageResponse, error: usageError } =
        useSwrFetcher<GetBrickUsageReponse>(`/api/bricks/${brick._id}`);
    const usageData = usageResponse?.data.data;

    return (
        <>
            <PageHeading title="Brick details">
                Edit this Brick and check or which Annotations use it.
            </PageHeading>
            <div className="space-y-6">
                <div className="space-y-2">
                    <h2 className="font-bold text-2xl border-t border-black border-opacity-10 pt-3">
                        Edit
                    </h2>
                    <Explanation>
                        View your Brick or edit it by changing its usage
                        category, its different translations or by deleting it.
                        Hit cancel below to exit without making any changes.
                    </Explanation>
                </div>
                <div className="space-y-2">
                    <h3 className="font-bold text-xl">Category</h3>
                    <FilterTabs
                        titles={[...brickCategories]}
                        selected={categoryIndex - 1}
                        setSelected={(newIndex) =>
                            setCategoryIndex(newIndex + 1)
                        }
                    ></FilterTabs>
                </div>
                <div className="space-y-2">
                    <h3 className="font-bold text-xl">Content</h3>
                    <Explanation>
                        <PlaceholderInfo />
                    </Explanation>
                    <BrickForm
                        category={categoryString as BrickCategory}
                        brick={brick}
                        mayDelete={
                            usageData?.drugs.length == 0 &&
                            usageData?.guidelines.length == 0
                        }
                    />
                </div>
                <BrickUsageList data={usageData} error={usageError} />
            </div>
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
