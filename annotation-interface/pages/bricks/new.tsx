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
            <PageHeading>Create new Brick</PageHeading>
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
