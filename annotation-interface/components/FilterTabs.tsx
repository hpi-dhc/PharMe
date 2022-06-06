import { Menu, Tab } from '@headlessui/react';
import { ChevronDownIcon } from '@heroicons/react/solid';
import { Dispatch, SetStateAction } from 'react';

import {
    supportedLanguages,
    SupportedLanguage,
    displayCategories,
} from '../common/constants';

export type DisplayFilterProps = {
    display: {
        categoryIndex: number;
        setCategoryIndex: Dispatch<SetStateAction<number>>;
        language: SupportedLanguage;
        setLanguage: Dispatch<SetStateAction<SupportedLanguage>>;
    };
};
type Props = { withLanguagePicker: boolean } & DisplayFilterProps;

const FilterTabs = ({
    withLanguagePicker,
    children,
    display,
}: React.PropsWithChildren<Props>) => {
    const categories = displayCategories;
    return (
        <Tab.Group
            selectedIndex={display.categoryIndex}
            onChange={display.setCategoryIndex}
        >
            <Tab.List className="space-x-4">
                {categories.map((tab, index) => (
                    <Tab
                        key={index}
                        className={({ selected }) =>
                            `float-left font-bold ${
                                selected && 'underline decoration-2'
                            }`
                        }
                    >
                        {tab}
                    </Tab>
                ))}
                {withLanguagePicker && (
                    <Menu as="div" className="inline float-right">
                        <Menu.Button className="inline-flex">
                            {display.language}
                            <ChevronDownIcon className="h-5 w-5 ml-2" />
                        </Menu.Button>
                        <Menu.Items className="absolute bg-white p-4 border border-black border-opacity-10">
                            {supportedLanguages.map((language, index) => (
                                <Menu.Item
                                    key={index}
                                    as="button"
                                    className={`block ${
                                        language == display.language &&
                                        'underline'
                                    }`}
                                    onClick={() =>
                                        display.setLanguage(language)
                                    }
                                >
                                    {language}
                                </Menu.Item>
                            ))}
                        </Menu.Items>
                    </Menu>
                )}
            </Tab.List>
            {children && (
                <Tab.Panels className="clear-both">{children}</Tab.Panels>
            )}
        </Tab.Group>
    );
};

export default FilterTabs;
