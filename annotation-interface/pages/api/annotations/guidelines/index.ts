import { NextApiHandler } from 'next';

import { createApi } from '../../../../common/api-helpers';
import GuidelineAnnotation from '../../../../database/models/GuidelineAnnotation';

const api: NextApiHandler = async (req, res) =>
    await createApi(GuidelineAnnotation!, req, res);

export default api;
