import { Tab } from '@headlessui/react';
import { ExclamationIcon, PlusCircleIcon } from '@heroicons/react/solid';
import { InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import DisplayLanguagePicker from '../../components/DisplayLanguagePicker';
import FilterTabs from '../../components/FilterTabs';
import Label from '../../components/Label';
import PageHeading from '../../components/PageHeading';
import {
    displayCategories,
    useBrickFilterContext,
} from '../../contexts/brickFilter';
import { useLanguageContext } from '../../contexts/language';
import dbConnect from '../../database/connect';
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
                accessory={<DisplayLanguagePicker />}
            >
                {displayCategories.map((category, categoryIndex) => (
                    <Tab.Panel key={categoryIndex}>
                        <div className="py-2">
                            <div className="flex justify-center p-2">
                                <Link href="/bricks/new">
                                    <a className="inline-flex p-3">
                                        <PlusCircleIcon className="h-5 w-5 mr-2"></PlusCircleIcon>
                                        Create new Brick
                                    </a>
                                </Link>
                            </div>
                            {(categoryIndex > 0
                                ? bricks.filter(
                                      (brick) => brick.usage === category,
                                  )
                                : bricks
                            ).map((brick, index) => (
                                <p
                                    key={index}
                                    className="border-t border-black border-opacity-10 py-3 pl-3"
                                >
                                    <Link
                                        key={index}
                                        href={`/bricks/${brick._id}`}
                                    >
                                        <a className="self-start mr-2">
                                            {brick.translations.find(
                                                (translation) =>
                                                    translation.language ===
                                                    language,
                                            )?.text ?? (
                                                <span className="inline-flex align-top">
                                                    <ExclamationIcon className="h-5 w-5 mr-2 pt-1" />
                                                    This Brick is not translated
                                                    to {language}.
                                                </span>
                                            )}
                                        </a>
                                    </Link>
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
                                </p>
                            ))}
                        </div>
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
