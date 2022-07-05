import { NextApiHandler } from 'next';

import { updateDeleteApi } from '../../../common/api-helpers';
import TextBrick from '../../../database/models/TextBrick';

const api: NextApiHandler = async (req, res) =>
    await updateDeleteApi(TextBrick!, req, res);

export default api;
