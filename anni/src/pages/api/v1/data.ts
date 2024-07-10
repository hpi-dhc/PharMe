import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../../common/api-helpers';
import dbConnect from '../../../database/helpers/connect';
import AppData, { IAppData_DB } from '../../../database/models/AppData';
import { IVersionedDoc } from '../../../database/versioning/schema';

export async function getAppDataOrThrowUnavailableError(): Promise<
    IVersionedDoc<IAppData_DB>
> {
    await dbConnect();
    const data = await AppData!.getCurrent();
    if (!data) throw new ApiError(503, 'Data not available');
    return data;
}

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            const data = await getAppDataOrThrowUnavailableError();
            return { successStatus: 200, data };
        },
    });

export default api;
