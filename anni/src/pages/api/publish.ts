import { NextApiHandler } from 'next';

import {
    ApiResponse,
    errorObject,
    handleApiMethods,
} from '../../common/api-helpers';
import { pharMeLanguage } from '../../common/definitions';
import dbConnect from '../../database/helpers/connect';
import AppData from '../../database/models/AppData';
import Drug from '../../database/models/Drug';

interface GetReponseData {
    errorMessage: string | null;
}

export type GetPublishStatusReponse = ApiResponse<GetReponseData>;

const getResolvedDrugs = async () => {
    const drugs = await Drug!.find({ isStaged: true }).exec();
    return await Promise.all(drugs.map((drug) => drug.resolve(pharMeLanguage)));
};

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            await dbConnect();
            const data: GetReponseData = { errorMessage: null };
            try {
                await getResolvedDrugs();
            } catch (error) {
                data.errorMessage =
                    errorObject(error)?.message ?? 'Unknown error';
            }
            return { successStatus: 200, data };
        },
        POST: async () => {
            await dbConnect();
            const drugs = await getResolvedDrugs();
            await AppData!.publish({ drugs });
            return { successStatus: 201 };
        },
    });

export default api;
