import { Menu } from '@headlessui/react';
import { ChevronDownIcon, AnnotationIcon } from '@heroicons/react/outline';

import WithIcon from '../WithIcon';

type SelectionPopoverProps<T extends string> = {
    label?: string;
    options: T[];
    onSelect: (value: T) => void;
    selectedOption?: T;
    icon?: typeof AnnotationIcon;
    expandUpwards?: boolean;
    justifyBetween?: boolean;
};

const SelectionPopover = <T extends string>({
    label,
    options,
    selectedOption,
    onSelect,
    icon,
    expandUpwards,
    justifyBetween,
}: SelectionPopoverProps<T>) => (
    <Menu as="div" className="inline self-center relative">
        <WithIcon
            as={Menu.Button}
            icon={icon ?? ChevronDownIcon}
            className={
                justifyBetween ? 'w-full flex-nowrap justify-between' : ''
            }
            reverse
        >
            <span>{label ?? selectedOption}</span>
        </WithIcon>
        <Menu.Items
            className={`${
                expandUpwards ? '-translate-y-full -top-2' : ''
            } absolute bg-white rounded-lg border border-black border-opacity-10 overflow-clip shadow-sm`}
        >
            {options.map((option, index) => (
                <Menu.Item
                    key={index}
                    as="button"
                    className={`w-full p-2 hover:bg-neutral-100 ${
                        index === options.length - 1 || 'border-b'
                    } ${option === selectedOption && 'underline'}`}
                    onClick={() => onSelect(option)}
                >
                    {option}
                </Menu.Item>
            ))}
        </Menu.Items>
    </Menu>
);

export default SelectionPopover;
