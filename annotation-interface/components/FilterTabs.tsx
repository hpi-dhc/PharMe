import { Tab } from '@headlessui/react';

import { supportedLanguages } from '../common/constants';
import {
    useBrickFilterContext,
    displayCategories,
} from '../contexts/brickFilter';
import { useLanguageContext } from '../contexts/language';
import SelectionPopover from './SelectionPopover';

type Props = React.PropsWithChildren<{
    withLanguagePicker?: boolean;
    withAllOption?: boolean;
}>;

const FilterTabs: React.FC<Props> = ({
    withLanguagePicker,
    withAllOption,
    children,
}: Props) => {
    const { language, setLanguage } = useLanguageContext();
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
                {withLanguagePicker && (
                    <SelectionPopover
                        options={[...supportedLanguages]}
                        selectedOption={language}
                        onSelect={setLanguage}
                    />
                )}
            </Tab.List>
            {children && <Tab.Panels>{children}</Tab.Panels>}
        </Tab.Group>
    );
};
FilterTabs.defaultProps = { withLanguagePicker: true, withAllOption: true };

export default FilterTabs;
