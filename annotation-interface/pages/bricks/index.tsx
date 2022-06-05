import { Tab } from '@headlessui/react';
import { ExclamationIcon, PlusCircleIcon } from '@heroicons/react/solid';
import { InferGetServerSidePropsType } from 'next';
import Link from 'next/link';

import { displayCategories } from '../../common/constants';
import FilterTabs, { DisplayFilterProps } from '../../components/FilterTabs';
import PageHeading from '../../components/PageHeading';
import dbConnect from '../../database/connect';
import TextBrick from '../../database/models/TextBrick';

const AllTextBricks = ({
    bricks,
    display,
}: InferGetServerSidePropsType<typeof getServerSideProps> &
    DisplayFilterProps) => {
    return (
        <>
            <PageHeading>Defined Bricks</PageHeading>
            <FilterTabs display={display}>
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
                                    <span className="mr-2">
                                        {brick.translations.find(
                                            (translation) =>
                                                translation.language ===
                                                display.language,
                                        )?.text ?? (
                                            <span className="inline-flex align-top">
                                                <ExclamationIcon className="h-5 w-5 mr-2 pt-1" />
                                                This Brick is not translated to{' '}
                                                {display.language}.
                                            </span>
                                        )}
                                    </span>
                                    <button
                                        className="border border-black border-opacity-20 text-xs px-2 rounded-full whitespace-nowrap font-semibold align-text-top mr-2"
                                        onClick={() =>
                                            display.setCategoryIndex(
                                                displayCategories.indexOf(
                                                    brick.usage,
                                                ),
                                            )
                                        }
                                    >
                                        {brick.usage}
                                    </button>
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
    const result = await TextBrick!.find({}).exec();
    const bricks = result.map((doc) => {
        const brick = doc.toObject();
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
