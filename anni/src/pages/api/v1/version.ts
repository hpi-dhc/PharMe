import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../../common/api-helpers';
import AppData from '../../../database/models/AppData';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            const version = await AppData!.getVersion();
            if (!version) throw new ApiError(503, 'Data not available');
            return { successStatus: 200, data: { version } };
        },
    });

export default api;
