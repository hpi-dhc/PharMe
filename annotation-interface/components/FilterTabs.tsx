import { Tab } from '@headlessui/react';
import { Dispatch, SetStateAction } from 'react';

import {
    supportedLanguages,
    SupportedLanguage,
    displayCategories,
} from '../common/constants';
import SelectionPopover from './SelectionPopover';

export type DisplayFilterProps = {
    display: {
        categoryIndex: number;
        setCategoryIndex: Dispatch<SetStateAction<number>>;
        language: SupportedLanguage;
        setLanguage: Dispatch<SetStateAction<SupportedLanguage>>;
    };
};
type Props = React.PropsWithChildren<
    DisplayFilterProps & {
        withLanguagePicker?: boolean;
        withAllOption?: boolean;
    }
>;

const FilterTabs: React.FC<Props> = ({
    display,
    withLanguagePicker,
    withAllOption,
    children,
}: Props) => {
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
        <Tab.Group
            selectedIndex={display.categoryIndex}
            onChange={display.setCategoryIndex}
        >
            <Tab.List className="flex justify-between">
                <div>{tabs}</div>
                {withLanguagePicker && (
                    <SelectionPopover
                        options={[...supportedLanguages]}
                        selectedOption={display.language}
                        onSelect={(language) => display.setLanguage(language)}
                    />
                )}
            </Tab.List>
            {children && <Tab.Panels>{children}</Tab.Panels>}
        </Tab.Group>
    );
};
FilterTabs.defaultProps = { withLanguagePicker: true, withAllOption: true };

export default FilterTabs;
