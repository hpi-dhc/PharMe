import { useRouter } from 'next/router';

import { BrickCategory, brickCategories } from '../../common/definitions';
import { useMountEffect } from '../../common/react-helpers';
import BrickForm from '../../components/bricks/BrickForm';
import PlaceholderInfo from '../../components/bricks/PlaceholderInfo';
import FilterTabs from '../../components/common/structure/FilterTabs';
import PageHeading from '../../components/common/structure/PageHeading';
import {
    DisplayCategory,
    displayCategoryForIndex,
    indexForDisplayCategory,
    useBrickFilterContext,
} from '../../contexts/brickFilter';

const NewBrick = () => {
    const { categoryIndex, setCategoryIndex } = useBrickFilterContext();
    const categoryString: string = displayCategoryForIndex(categoryIndex);

    const router = useRouter();
    const { usage } = router.query;
    if (
        usage &&
        (brickCategories as readonly string[]).includes(usage as string)
    ) {
        setCategoryIndex(indexForDisplayCategory(usage as DisplayCategory));
    }

    useMountEffect(() => {
        if (!(brickCategories as readonly string[]).includes(categoryString)) {
            setCategoryIndex(
                indexForDisplayCategory(brickCategories[0] as DisplayCategory),
            );
        }
    });

    return (
        <>
            <PageHeading title="Create new Brick">
                <p>
                    Create a new Brick by specifying the annotation text
                    category it&apos;ll be used for and defining it in at least
                    one language.
                </p>
                <PlaceholderInfo />
            </PageHeading>
            <FilterTabs
                titles={[...brickCategories]}
                selected={categoryIndex - 1}
                setSelected={(newIndex) => setCategoryIndex(newIndex + 1)}
            ></FilterTabs>
            <BrickForm
                category={categoryString as BrickCategory}
                mayDelete={false}
            />
        </>
    );
};

export default NewBrick;
