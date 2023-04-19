import { NextApiHandler } from 'next';

import { updateDeleteApi } from '../../../common/api-helpers';
import dbConnect from '../../../database/helpers/connect';
import Drug from '../../../database/models/Drug';
import TextBrick from '../../../database/models/TextBrick';
import { drugAnnotationsResponseData } from '../annotations/index';

const api: NextApiHandler = async (req, res) =>
    await updateDeleteApi(TextBrick!, req, res, {
        GET: async () => {
            await dbConnect();
            const {
                query: { id },
            } = req;
            const drugs = await Drug!
                .find({
                    $or: [
                        { 'annotations.drugclass': { $in: [id] } },
                        { 'annotations.indication': { $in: [id] } },
                    ],
                })
                .exec();

            const data = await drugAnnotationsResponseData(drugs);
            return { successStatus: 200, data };
        },
    });

export default api;
