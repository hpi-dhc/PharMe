import mongoose from 'mongoose';
import { NextApiRequest, NextApiResponse } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import dbConnect from '../database/helpers/connect';

type ApiMethodHandlers = {
    [key: string]: () => Promise<{ successStatus: number; data?: object }>;
};

export const handleApiMethods = async (
    req: NextApiRequest,
    res: NextApiResponse,
    methodHandlers: ApiMethodHandlers,
): Promise<void> => {
    const { method } = req;
    try {
        if (!method) throw new ApiError(400, 'Method not defined');
        const handler = methodHandlers[method];
        if (!handler) throw new ApiError(400, 'Method not supported');
        const { successStatus, data } = await handler();
        res.status(successStatus).json({ success: true, data });
    } catch (error) {
        /* eslint-disable no-console */
        console.error(error);
        /* eslint-disable @typescript-eslint/no-explicit-any */
        const apiError =
            error && typeof error === 'object' ? (error as any) : undefined;
        const statusCode = apiError?.statusCode ?? 400;
        const message = apiError?.message ?? 'Unknown error';
        res.status(statusCode).json({ success: false, message });
    }
};

export const createApi = async (
    /* eslint-disable @typescript-eslint/no-explicit-any */
    model: mongoose.Model<any>,
    req: NextApiRequest,
    res: NextApiResponse,
    additionalMethodHandlers: ApiMethodHandlers | undefined = undefined,
): Promise<void> => {
    await handleApiMethods(req, res, {
        POST: async () => {
            await dbConnect();
            const doc = await model.create(req.body);
            return { successStatus: 201, data: doc };
        },
        ...additionalMethodHandlers,
    });
};

export const updateDeleteApi = async (
    model: mongoose.Model<any>,
    req: NextApiRequest,
    res: NextApiResponse,
    additionalMethodHandlers: ApiMethodHandlers | undefined = undefined,
): Promise<void> => {
    const {
        query: { id },
    } = req;
    await handleApiMethods(req, res, {
        PUT: async () => {
            await dbConnect();
            const doc = await model
                .findByIdAndUpdate(id, req.body, {
                    new: true,
                    runValidators: true,
                })
                .orFail();
            return { successStatus: 200, data: doc };
        },
        DELETE: async () => {
            await dbConnect();
            await model.findByIdAndDelete(id).orFail();
            return { successStatus: 204 };
        },
        ...additionalMethodHandlers,
    });
};
