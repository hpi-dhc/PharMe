import { Menu } from '@headlessui/react';
import { ChevronDownIcon } from '@heroicons/react/outline';

type SelectionPopoverProps<T extends string> = {
    label?: string;
    options: T[];
    onSelect: (value: T) => void;
    selectedOption?: T;
};

const SelectionPopover = <T extends string>({
    label,
    options,
    selectedOption,
    onSelect,
}: SelectionPopoverProps<T>) => (
    <Menu as="div" className="inline">
        <Menu.Button className="inline-flex">
            {label ?? selectedOption}
            <ChevronDownIcon className="h-5 w-5 ml-2" />
        </Menu.Button>
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
