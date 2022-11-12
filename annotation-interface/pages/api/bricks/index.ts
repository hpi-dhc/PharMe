import { NextApiHandler } from 'next';

import { ApiResponse, createApi } from '../../../common/api-helpers';
import dbConnect from '../../../database/helpers/connect';
import { makeIdsStrings } from '../../../database/helpers/types';
import TextBrick, { ITextBrick_Str } from '../../../database/models/TextBrick';

export type GetBricksQuery = Partial<ITextBrick_Str>;
interface Response {
    bricks: Array<ITextBrick_Str>;
}
export type GetBricksResponse = ApiResponse<Response>;

const api: NextApiHandler = async (req, res) =>
    await createApi(TextBrick!, req, res, {
        GET: async () => {
            await dbConnect();
            const filter = req.query;
            const docs = await TextBrick!.find(filter).lean().orFail().exec();
            const bricks: Response = {
                bricks: docs.map(
                    (doc) => makeIdsStrings(doc) as ITextBrick_Str,
                ),
            };
            return { successStatus: 200, data: { bricks } };
        },
    });

export default api;
