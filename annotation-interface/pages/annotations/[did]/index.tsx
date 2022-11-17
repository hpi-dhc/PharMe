import {
    GetServerSidePropsContext,
    GetServerSidePropsResult,
    InferGetServerSidePropsType,
} from 'next';
import { useState } from 'react';
import { resetServerContext } from 'react-beautiful-dnd';

import { annotationComponent } from '../../../common/definitions';
import { matches } from '../../../common/generic-helpers';
import { BackToAnnotations } from '../../../components/annotations/AbstractAnnotation';
import Label from '../../../components/common/Label';
import PageHeading from '../../../components/common/PageHeading';
import SearchBar from '../../../components/common/SearchBar';
import TableRow from '../../../components/common/TableRow';
import dbConnect from '../../../database/helpers/connect';
import {
    guidelineDisplayName,
    missingGuidelineAnnotations,
} from '../../../database/helpers/guideline-data';
import { makeIdsStrings } from '../../../database/helpers/types';
import { IGuideline_DB } from '../../../database/models/Guideline';
import Medication, {
    IMedication_Populated,
} from '../../../database/models/Medication';
import { ITextBrick_Str } from '../../../database/models/TextBrick';

const DrugDetail = ({
    drug,
}: InferGetServerSidePropsType<typeof getServerSideProps>) => {
    const [guidelineQuery, setGuidelineQuery] = useState('');
    const guidelines = drug.guidelines.filter((guideline) =>
        matches(guidelineDisplayName(guideline), guidelineQuery),
    );
    return (
        <>
            <PageHeading title={`Drug: ${drug.name}`}>
                View and edit annotations for this drug, i.e. its
                patient-friendly drug class and its indication.
            </PageHeading>
            <div className="space-y-4">
                <BackToAnnotations />
                {annotationComponent.drugclass(drug)}
                {annotationComponent.indication(drug)}
                <h2 className="font-bold border-t border-black border-opacity-20 pt-4">
                    Guidelines
                </h2>
                <SearchBar
                    query={guidelineQuery}
                    setQuery={setGuidelineQuery}
                />
                <div>
                    {guidelines?.map((guideline) => (
                        <TableRow
                            key={guideline._id}
                            link={`/annotations/${drug._id}/${guideline._id}`}
                        >
                            <div className="flex justify-between">
                                <span className="mr-2">
                                    {guidelineDisplayName(guideline)}
                                </span>
                                <span>
                                    <Label
                                        title={`${missingGuidelineAnnotations(
                                            guideline,
                                        )} missing`}
                                    />
                                </span>
                            </div>
                        </TableRow>
                    ))}
                </div>
            </div>
        </>
    );
};

export default DrugDetail;

export const getServerSideProps = async (
    context: GetServerSidePropsContext,
): Promise<
    GetServerSidePropsResult<{
        drug: IMedication_Populated;
    }>
> => {
    const id = context.params?.did as string;
    if (!id) return { notFound: true };
    resetServerContext();
    try {
        await dbConnect();
        const drug = await Medication!
            .findById(id)
            .populate<{
                'annotations.drugclass': Array<ITextBrick_Str> | undefined;
                'annotations.indication': Array<ITextBrick_Str> | undefined;
                guidelines: IGuideline_DB;
            }>([
                'annotations',
                'annotations.drugclass',
                'annotations.indication',
                'guidelines',
            ])
            .orFail()
            .exec();
        return {
            props: { drug: makeIdsStrings(drug) as IMedication_Populated },
        };
    } catch (error) {
        return { notFound: true };
    }
};
