import { Tab } from '@headlessui/react';
import { ExclamationIcon, PlusCircleIcon } from '@heroicons/react/solid';
import { InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import WithIcon from '../../components/common/WithIcon';
import Label from '../../components/common/indicators/Label';
import TableRow from '../../components/common/interaction/TableRow';
import FilterTabs from '../../components/common/structure/FilterTabs';
import PageHeading from '../../components/common/structure/PageHeading';
import {
    displayCategories,
    useBrickFilterContext,
} from '../../contexts/brickFilter';
import { useLanguageContext } from '../../contexts/language';
import dbConnect from '../../database/helpers/connect';
import TextBrick from '../../database/models/TextBrick';

const AllTextBricks = ({
    bricks,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const { language } = useLanguageContext();
    const { categoryIndex, setCategoryIndex } = useBrickFilterContext();
    return (
        <>
            <PageHeading title="Defined Bricks">
                <>
                    <span className="italic">Bricks</span> are predefined
                    components that are used to create texts for{' '}
                    <Link href="/annotations">
                        <a className="italic underline">annotations</a>
                    </Link>
                    . The creation of annotation texts is strictly limited to
                    combinations of Bricks to ensure consistency and enable easy
                    multi-language support. Bricks can also include placeholders
                    such as a given drug&apos;s name.
                </>
            </PageHeading>
            <FilterTabs
                titles={[...displayCategories]}
                selected={categoryIndex}
                setSelected={setCategoryIndex}
            >
                {displayCategories.map((category, categoryIndex) => (
                    <Tab.Panel key={categoryIndex}>
                        <div className="flex justify-center p-4">
                            <Link href="/bricks/new">
                                <a>
                                    <WithIcon icon={PlusCircleIcon}>
                                        Create new Brick
                                    </WithIcon>
                                </a>
                            </Link>
                        </div>
                        {(categoryIndex > 0
                            ? bricks.filter((brick) => brick.usage === category)
                            : bricks
                        ).map((brick, index) => (
                            <TableRow key={index} link={`/bricks/${brick._id}`}>
                                <>
                                    <span className="mr-2">
                                        {brick.translations.find(
                                            (translation) =>
                                                translation.language ===
                                                language,
                                        )?.text ?? (
                                            <WithIcon
                                                icon={ExclamationIcon}
                                                className="align-top"
                                            >
                                                This Brick is not translated to{' '}
                                                {language}
                                            </WithIcon>
                                        )}
                                    </span>
                                    <Label
                                        as="button"
                                        title={brick.usage}
                                        onClick={() =>
                                            setCategoryIndex(
                                                displayCategories.indexOf(
                                                    brick.usage,
                                                ),
                                            )
                                        }
                                    />
                                </>
                            </TableRow>
                        ))}
                    </Tab.Panel>
                ))}
            </FilterTabs>
        </>
    );
};

export default AllTextBricks;

export const getServerSideProps = async () => {
    await dbConnect();
    const result = await TextBrick!.find().lean().exec();
    const bricks = result.map((brick) => {
        return {
            ...brick,
            _id: brick._id!.toString(),
            translations: brick.translations.map((translation) => {
                return { ...translation, _id: translation._id!.toString() };
            }),
        };
    });
    return { props: { bricks } };
};
