import {
    BrickUsage,
    brickUsages,
    displayCategoryForIndex,
} from '../../common/constants';
import BrickForm from '../../components/BrickForm';
import FilterTabs, { DisplayFilterProps } from '../../components/FilterTabs';
import PageHeading from '../../components/PageHeading';

const NewBrick = ({ display }: DisplayFilterProps) => {
    const categoryString: string = displayCategoryForIndex(
        display.categoryIndex,
    );
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
                display={display}
            ></FilterTabs>
            <BrickForm usage={usage} />
        </>
    );
};

export default NewBrick;
