import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../../common/api-helpers';
import { AnnotationKey } from '../../../common/definitions';
import dbConnect from '../../../database/helpers/connect';
import Guideline from '../../../database/models/Guideline';
import Medication from '../../../database/models/Medication';

/* eslint-disable @typescript-eslint/no-explicit-any */

export interface UpdateAnnotationBody {
    key: AnnotationKey;
    newValue: any;
}

const allAnnotationModels = [Medication!, Guideline!];

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        PATCH: async () => {
            await dbConnect();
            const {
                query: { id },
            } = req;
            const { key, newValue } = req.body as UpdateAnnotationBody;
            const model = allAnnotationModels.find((model) =>
                Object.keys(
                    model.schema.paths.annotations.schema.paths,
                ).includes(key),
            );
            if (!model) {
                throw new ApiError(400, 'Unknown Annotation type');
            }
            await (model as any)
                .findByIdAndUpdate(id, {
                    [`annotations.${key}`]: newValue,
                })
                .orFail();
            return { successStatus: 200 };
        },
    });

export default api;
