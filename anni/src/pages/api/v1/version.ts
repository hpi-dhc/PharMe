import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { ApiResponse, handleApiMethods } from '../../../common/api-helpers';
import dbConnect from '../../../database/helpers/connect';
import AppData from '../../../database/models/AppData';

interface GetReponseData {
    version: number;
}

export type GetCurrentVersionResponse = ApiResponse<GetReponseData>;

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            await dbConnect();
            const version = await AppData!.getVersion();
            if (!version) throw new ApiError(503, 'Data not available');
            return { successStatus: 200, data: { version } };
        },
    });

export default api;
