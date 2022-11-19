import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../common/api-helpers';
import {
    SupportedLanguage,
    supportedLanguages,
} from '../../common/definitions';
import dbConnect from '../../database/helpers/connect';
import Medication from '../../database/models/Medication';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            const language = req.query.language as SupportedLanguage;
            if (!(language && supportedLanguages.includes(language))) {
                throw new ApiError(400, 'Language not specified.');
            }

            await dbConnect();
            const medications = await Medication!.find({}).exec();
            const resolved = await Promise.all(
                medications.map((medication) => medication.resolve(language)),
            );
            return {
                successStatus: 200,
                data: resolved,
            };
        },
    });

export default api;
