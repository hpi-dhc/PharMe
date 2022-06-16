import { BrickUsage, brickUsages } from '../../common/constants';
import BrickForm from '../../components/BrickForm';
import FilterTabs from '../../components/FilterTabs';
import PageHeading from '../../components/PageHeading';
import {
    displayCategoryForIndex,
    useBrickFilterContext,
} from '../../contexts/brickFilter';

const NewBrick = () => {
    const { categoryIndex } = useBrickFilterContext();
    const categoryString: string = displayCategoryForIndex(categoryIndex);
    const usage = (brickUsages as readonly string[]).includes(categoryString)
        ? (categoryString as BrickUsage)
        : null;
    return (
        <>
            <PageHeading title="Create new Brick">
                Create a new Brick by specifying the annotation text category
                it&apos;ll be used for and defining it in at least one language.
            </PageHeading>
            <FilterTabs
                withLanguagePicker={false}
                withAllOption={false}
            ></FilterTabs>
            <BrickForm usage={usage} />
        </>
    );
};

export default NewBrick;
