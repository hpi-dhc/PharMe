import { NextApiHandler } from 'next';

import { createApi } from '../../../common/api-helpers';
import TextBrick from '../../../database/models/TextBrick';

const api: NextApiHandler = async (req, res) =>
    await createApi(TextBrick!, req, res);

export default api;
