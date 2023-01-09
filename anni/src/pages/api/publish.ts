import { NextApiHandler } from 'next';

import { handleApiMethods } from '../../common/api-helpers';
import { pharMeLanguage } from '../../common/definitions';
import dbConnect from '../../database/helpers/connect';
import AppData from '../../database/models/AppData';
import Drug from '../../database/models/Drug';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        POST: async () => {
            await dbConnect();
            const drugs = await Drug!.find({ isStaged: true }).exec();
            const resolved = await Promise.all(
                drugs.map((drug) => drug.resolve(pharMeLanguage)),
            );
            await AppData!.publish({ drugs: resolved });
            return { successStatus: 201 };
        },
    });

export default api;
