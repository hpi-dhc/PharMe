import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { ApiResponse, handleApiMethods } from '../../../../common/api-helpers';
import dbConnect from '../../../../database/helpers/connect';
import { allAnnotationModels, AnyAnnotationModel } from '../[id]';

/* eslint-disable @typescript-eslint/no-explicit-any */

interface ResponseData {
    isStaged: boolean;
}
export type GetStagingResponse = ApiResponse<ResponseData>;

export interface UpdateStagingBody {
    isStaged: 'true' | 'false';
}

async function execOrFail<T>(
    f: (model: AnyAnnotationModel) => Promise<T>,
): Promise<T> {
    await dbConnect();
    const results = await Promise.all(
        allAnnotationModels.map(async (model): Promise<T | undefined> => {
            const result = await f(model);
            if (result) return result;
            return undefined;
        }),
    );
    const ret = results.find((result) => result);
    if (!ret) throw new ApiError(404, 'Annotation document not found.');
    return ret;
}

const api: NextApiHandler = async (req, res) => {
    const {
        query: { id },
    } = req;

    await handleApiMethods(req, res, {
        GET: async () => {
            const doc = await execOrFail(
                async (model) =>
                    await (model as any).findById(id).lean().exec(),
            );
            const data: ResponseData = {
                isStaged: doc.isStaged,
            };
            return { successStatus: 200, data };
        },
        PATCH: async () => {
            const { isStaged } = req.body as UpdateStagingBody;
            await execOrFail(
                async (model) =>
                    await (model as any).findByIdAndUpdate(id, {
                        isStaged: isStaged === 'true' ? true : false,
                    }),
            );
            return { successStatus: 200 };
        },
    });
};

export default api;
