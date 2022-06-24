import { BrickUsage, brickUsages } from '../../common/constants';
import { useMountEffect } from '../../common/react-helpers';
import BrickForm from '../../components/bricks/BrickForm';
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
                Create a new Brick by specifying the annotation text category
                it&apos;ll be used for and defining it in at least one language.
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
