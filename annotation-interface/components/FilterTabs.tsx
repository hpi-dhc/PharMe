import { Tab } from '@headlessui/react';

import {
    useBrickFilterContext,
    displayCategories,
} from '../contexts/brickFilter';

type Props = React.PropsWithChildren<{
    accessory?: JSX.Element;
    withAllOption?: boolean;
}>;

const FilterTabs: React.FC<Props> = ({
    accessory,
    withAllOption,
    children,
}: Props) => {
    const { categoryIndex, setCategoryIndex } = useBrickFilterContext();
    const tabs = displayCategories.map((category, index) => {
        if (!withAllOption && category === 'All') {
            return <Tab key={index} />;
        }
        return (
            <Tab
                key={index}
                className={({ selected }) =>
                    `font-bold mr-4 ${selected && 'underline decoration-2'}`
                }
            >
                {category}
            </Tab>
        );
    });

    return (
        <Tab.Group selectedIndex={categoryIndex} onChange={setCategoryIndex}>
            <Tab.List className="flex justify-between">
                <div>{tabs}</div>
                {accessory && accessory}
            </Tab.List>
            {children && <Tab.Panels>{children}</Tab.Panels>}
        </Tab.Group>
    );
};
FilterTabs.defaultProps = { withAllOption: true };

export default FilterTabs;
