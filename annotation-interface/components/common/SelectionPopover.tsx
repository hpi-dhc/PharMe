import { Menu } from '@headlessui/react';
import { ChevronDownIcon, AnnotationIcon } from '@heroicons/react/outline';

import WithIcon from './WithIcon';

type SelectionPopoverProps<T extends string> = {
    label?: string;
    options: T[];
    onSelect: (value: T) => void;
    selectedOption?: T;
    icon?: typeof AnnotationIcon;
};

const SelectionPopover = <T extends string>({
    label,
    options,
    selectedOption,
    onSelect,
    icon,
}: SelectionPopoverProps<T>) => (
    <Menu as="div" className="inline self-center px-2">
        <WithIcon as={Menu.Button} icon={icon ?? ChevronDownIcon}>
            {label ?? selectedOption}
        </WithIcon>
        <Menu.Items className="absolute bg-white p-4 border border-black border-opacity-10">
            {options.map((option, index) => (
                <Menu.Item
                    key={index}
                    as="button"
                    className={`block ${
                        option === selectedOption && 'underline'
                    }`}
                    onClick={() => onSelect(option)}
                >
                    {option}
                </Menu.Item>
            ))}
        </Menu.Items>
    </Menu>
);

export default SelectionPopover;
