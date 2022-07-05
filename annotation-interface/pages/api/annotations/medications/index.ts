import { NextApiHandler } from 'next';

import { createApi } from '../../../../common/api-helpers';
import MedAnnotation from '../../../../database/models/MedAnnotation';

const api: NextApiHandler = async (req, res) =>
    await createApi(MedAnnotation!, req, res);

export default api;
