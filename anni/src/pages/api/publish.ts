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

interface PostReponseData {
    newVersion: number;
}

export type GetPublishStatusReponse = ApiResponse<GetReponseData>;
export type PublishResponse = ApiResponse<PostReponseData>;

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
            const appData = await AppData!.publish({ drugs });
            const data: PostReponseData = {
                newVersion: appData._v,
            };
            return { successStatus: 201, data };
        },
    });

export default api;
