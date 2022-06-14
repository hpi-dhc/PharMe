import { Tab } from '@headlessui/react';

type Props = React.PropsWithChildren<{
    titles: string[];
    selected: number;
    setSelected: (index: number) => void;
    accessory?: JSX.Element;
}>;

const FilterTabs: React.FC<Props> = ({
    titles,
    selected,
    setSelected,
    accessory,
    children,
}: Props) => {
    const tabs = titles.map((title, index) => (
        <Tab
            key={index}
            className={({ selected }) =>
                `font-bold mr-4 ${selected && 'underline decoration-2'}`
            }
        >
            {title}
        </Tab>
    ));

    return (
        <Tab.Group selectedIndex={selected} onChange={setSelected}>
            <Tab.List className="flex justify-between">
                <div>{tabs}</div>
                {accessory && accessory}
            </Tab.List>
            {children && <Tab.Panels className="py-2">{children}</Tab.Panels>}
        </Tab.Group>
    );
};

export default FilterTabs;
