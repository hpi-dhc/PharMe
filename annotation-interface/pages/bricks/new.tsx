import { useRouter } from 'next/router';

import { BrickUsage, brickUsages } from '../../common/definitions';
import { useMountEffect } from '../../common/react-helpers';
import BrickForm from '../../components/bricks/BrickForm';
import PlaceholderInfo from '../../components/bricks/PlaceholderInfo';
import FilterTabs from '../../components/common/FilterTabs';
import PageHeading from '../../components/common/PageHeading';
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
    if (usage && (brickUsages as readonly string[]).includes(usage as string)) {
        setCategoryIndex(indexForDisplayCategory(usage as DisplayCategory));
    }

    useMountEffect(() => {
        if (!(brickUsages as readonly string[]).includes(categoryString)) {
            setCategoryIndex(
                indexForDisplayCategory(brickUsages[0] as DisplayCategory),
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
                titles={[...brickUsages]}
                selected={categoryIndex - 1}
                setSelected={(newIndex) => setCategoryIndex(newIndex + 1)}
            ></FilterTabs>
            <BrickForm usage={categoryString as BrickUsage} />
        </>
    );
};

export default NewBrick;
