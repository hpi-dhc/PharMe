import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../common/api-helpers';
import {
    SupportedLanguage,
    supportedLanguages,
} from '../../common/definitions';
import dbConnect from '../../database/helpers/connect';
import Drug from '../../database/models/Drug';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            const language = req.query.language as SupportedLanguage;
            if (!(language && supportedLanguages.includes(language))) {
                throw new ApiError(400, 'Language not specified.');
            }

            await dbConnect();
            const drugs = await Drug!.find({ isStaged: true }).exec();
            const resolved = await Promise.all(
                drugs.map((drug) => drug.resolve(language)),
            );
            return {
                successStatus: 200,
                data: resolved,
            };
        },
    });

export default api;
