import { forwardRef, useImperativeHandle, useState } from 'react';

import { mod } from '../../common/generic-helpers';

export type AutoCompleteMenuRef = {
    pickSelected: () => void;
    moveSelection: (offset: number) => void;
};
type Props = {
    query: string;
    options: string[];
    pickOption: (option: string) => void;
};

const AutocompleteMenu = forwardRef<AutoCompleteMenuRef, Props>(
    ({ query, options, pickOption }, ref) => {
        const [selection, setSelection] = useState<number | null>(null);
        const filteredOptions =
            query === ''
                ? options
                : options.filter((option) =>
                      option.toLowerCase().includes(query),
                  );
        useImperativeHandle(ref, () => ({
            pickSelected() {
                if (selection !== null && selection < filteredOptions.length) {
                    pickOption(filteredOptions[selection]);
                }
            },
            moveSelection(offset: number) {
                if (filteredOptions.length === 0) setSelection(null);
                else if (selection === null) setSelection(0);
                else {
                    setSelection(
                        mod(selection + offset, filteredOptions.length),
                    );
                }
            },
        }));

        return (
            <ul className="absolute z-20 text-black bg-white border border-black border-opacity-10 divide-y min-w-max">
                {filteredOptions.map((option, index) => (
                    <li className="p-2" key={index} value={option}>
                        <button
                            className={`text-left break-inside-avoid ${
                                selection == index && 'underline'
                            }`}
                            onClick={() => pickOption(option)}
                            onMouseOver={() => setSelection(index)}
                        >
                            {option}
                        </button>
                    </li>
                ))}
            </ul>
        );
    },
);
AutocompleteMenu.displayName = 'AutocompleteMenu';

export default AutocompleteMenu;
