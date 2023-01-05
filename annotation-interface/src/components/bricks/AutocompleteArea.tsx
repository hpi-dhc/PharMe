import { ReactNode, SyntheticEvent, useRef, useState } from 'react';

import AutocompleteMenu, { AutoCompleteMenuRef } from './AutocompleteMenu';

type Props = {
    value: string;
    onChange: (text: string) => void;
    validPlaceholders: string[];
};

const AutocompleteArea = ({
    value: text,
    onChange: setText,
    validPlaceholders,
}: Props) => {
    const [selection, setSelection] = useState<
        [start: number, end: number] | null
    >(null);
    const setSelectionFromEvent = (e: SyntheticEvent<HTMLTextAreaElement>) => {
        setSelection([
            e.currentTarget.selectionStart,
            e.currentTarget.selectionEnd,
        ]);
    };
    const textarea = useRef<null | HTMLTextAreaElement>(null);
    if (selection) textarea.current?.setSelectionRange(...selection);

    const completionMenu = useRef<null | AutoCompleteMenuRef>(null);
    const getCompletionMenu = (match: RegExpMatchArray) => {
        const insertPlaceholder = (placeholder: string) => {
            setText(
                text.slice(0, match.index! + 1) +
                    placeholder +
                    text.slice(match.index! + match[0].length),
            );
            textarea.current?.focus();
            const newPos = match.index! + 1 + placeholder.length;
            setSelection([newPos, newPos]);
        };
        return (
            <AutocompleteMenu
                ref={completionMenu}
                query={match.groups!.placeholder}
                options={validPlaceholders}
                pickOption={insertPlaceholder}
            />
        );
    };

    const getHighlighting = () => {
        let index = 0;
        const elements: ReactNode[] = [];
        const placeHolderAreas = [...text.matchAll(/#(?<placeholder>\S*)/g)];
        placeHolderAreas.forEach((match, key) => {
            elements.push(text.slice(index, match.index!));
            index = match.index! + match[0].length;
            const diff = (selection?.[0] ?? Infinity) - match.index!;
            const hasCursor = diff > 0 && diff <= match[0].length;
            elements.push(
                <span
                    key={key}
                    className={`relative ${
                        validPlaceholders.includes(match.groups!.placeholder) &&
                        'underline decoration-black'
                    }`}
                >
                    {match[0]}
                    {hasCursor && getCompletionMenu(match)}
                </span>,
            );
        });
        elements.push(text.slice(index) + '\n\n');
        return elements;
    };

    return (
        <div className="relative">
            <div className="whitespace-pre-wrap break-words p-2 text-transparent">
                {getHighlighting()}
            </div>
            <textarea
                className="resize-none w-full h-full border border-black border-opacity-10 absolute top-0 left-0 z-10 bg-transparent p-2"
                ref={textarea}
                value={text}
                onBlur={() => setSelection(null)}
                onChange={(e) => {
                    setText(e.target.value);
                    setSelectionFromEvent(e);
                }}
                onKeyUp={setSelectionFromEvent}
                onClick={setSelectionFromEvent}
                onKeyDown={(e) => {
                    const menu = completionMenu.current;
                    if (!menu) return;
                    switch (e.key) {
                        case 'ArrowUp':
                            menu.moveSelection(-1);
                            break;
                        case 'ArrowDown':
                            menu.moveSelection(1);
                            break;
                        case 'Enter':
                            menu.pickSelected();
                            break;
                        default:
                            return;
                    }
                    e.preventDefault();
                }}
            />
        </div>
    );
};

export default AutocompleteArea;
