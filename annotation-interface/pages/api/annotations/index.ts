import { NextApiHandler } from 'next';

import { ApiResponse, handleApiMethods } from '../../../common/api-helpers';
import { CurationState } from '../../../database/helpers/annotations';
import dbConnect from '../../../database/helpers/connect';
import Drug, { IDrug_Str } from '../../../database/models/Drug';

interface ResponseData {
    drugs: Array<
        Pick<IDrug_Str, '_id' | 'name' | 'isStaged'> & {
            curationState: CurationState;
        }
    >;
}
export type GetAnnotationsReponse = ApiResponse<ResponseData>;

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            await dbConnect();
            const drugs = await Drug!.find({}).orFail().exec();
            const curationStates = await Promise.all(
                drugs.map((drug) => drug.curationState()),
            );
            const data: ResponseData = {
                drugs: drugs.map((drug, index) => {
                    return {
                        _id: drug._id!.toString(),
                        name: drug.name,
                        isStaged: drug.isStaged,
                        curationState: curationStates[index],
                    };
                }),
            };
            return { successStatus: 200, data };
        },
    });

export default api;
