import { NextApiHandler } from 'next';

import { ApiResponse, updateDeleteApi } from '../../../common/api-helpers';
import { CurationState } from '../../../database/helpers/annotations';
import dbConnect from '../../../database/helpers/connect';
import { guidelineCurationState } from '../../../database/helpers/guideline-data';
import { makeIdsStrings } from '../../../database/helpers/types';
import Drug, { IDrug_Str } from '../../../database/models/Drug';
import Guideline, { IGuideline_Str } from '../../../database/models/Guideline';
import TextBrick from '../../../database/models/TextBrick';
import { drugAnnotationsResponseData } from '../annotations/index';

interface ResponseData {
    drugs: Array<
        Pick<IDrug_Str, '_id' | 'name' | 'isStaged'> & {
            curationState: CurationState;
        }
    >;
    guidelines: Array<
        IGuideline_Str & {
            drug: Pick<IDrug_Str, '_id' | 'name'>;
            curationState: CurationState;
        }
    >;
}
export type GetBrickUsageReponse = ApiResponse<ResponseData>;

const api: NextApiHandler = async (req, res) =>
    await updateDeleteApi(TextBrick!, req, res, {
        GET: async () => {
            await dbConnect();
            const {
                query: { id },
            } = req;
            const drugs = await Drug!
                .find({
                    $or: [
                        { 'annotations.drugclass': { $in: [id] } },
                        { 'annotations.indication': { $in: [id] } },
                    ],
                })
                .exec();

            const guidelines = await Guideline!
                .find({
                    $or: [
                        { 'annotations.implication': { $in: [id] } },
                        { 'annotations.recommendation': { $in: [id] } },
                    ],
                })
                .lean()
                .exec();

            const data: ResponseData = {
                drugs: await drugAnnotationsResponseData(drugs),
                guidelines: await Promise.all(
                    guidelines.map(async (guideline) => {
                        const drug = await Drug!
                            .findOne({
                                guidelines: { $in: [guideline._id] },
                            })
                            .lean()
                            .orFail()
                            .exec();
                        return {
                            ...makeIdsStrings(guideline),
                            drug: {
                                name: drug.name,
                                _id: drug._id.toString(),
                            },
                            curationState: guidelineCurationState(guideline),
                        };
                    }),
                ),
            };
            return { successStatus: 200, data };
        },
    });

export default api;
