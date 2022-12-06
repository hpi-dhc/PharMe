import { NextApiHandler } from 'next';

import { ApiResponse, handleApiMethods } from '../../../common/api-helpers';
import dbConnect from '../../../database/helpers/connect';
import Drug from '../../../database/models/Drug';

interface ResponseData {
    drugs: Array<{ id: string; name: string; badge: number }>;
}
export type GetAnnotationsReponse = ApiResponse<ResponseData>;

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            await dbConnect();
            const drugs = await Drug!.find({}).orFail().exec();
            const badges = await Promise.all(
                drugs.map((drug) => drug.missingAnnotations()),
            );
            const data: ResponseData = {
                drugs: drugs.map((drug, index) => {
                    return {
                        id: drug._id!.toString(),
                        name: drug.name,
                        badge: badges[index],
                    };
                }),
            };
            return { successStatus: 200, data };
        },
    });

export default api;
