import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../../../common/api-helpers';
import dbConnect from '../../../../database/helpers/connect';
import { allAnnotationModels } from '../[id]';

/* eslint-disable @typescript-eslint/no-explicit-any */

const modelAndDoc = async (id: string) => {
    await dbConnect();
    const results = await Promise.all(
        allAnnotationModels.map(
            async (model): Promise<[any, any] | undefined> => {
                const doc = await (model as any).findById(id).lean().exec();
                if (doc) return [model, doc];
                return undefined;
            },
        ),
    );
    const ret = results.find((result) => result);
    if (!ret)
        throw new ApiError(404, `Annotation Document with id ${id} not found`);
    return ret;
};

const api: NextApiHandler = async (req, res) => {
    const {
        query: { id },
    } = req;

    return await handleApiMethods(req, res, {
        GET: async () => {
            const [, doc] = await modelAndDoc(id as string);
            return { successStatus: 200, data: { isStaged: doc.isStaged } };
        },
    });
};

export default api;
