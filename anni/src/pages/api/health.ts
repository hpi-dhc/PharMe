import { NextApiHandler } from 'next';

import { getAppDataOrThrowUnavailableError } from './v1/data';
import { handleApiMethods } from '../../common/api-helpers';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            // Test if getting app data works, otherwise error is thrown
            await getAppDataOrThrowUnavailableError();
            return { successStatus: 200 };
        },
    });

export default api;
