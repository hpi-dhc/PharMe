import mongoose from 'mongoose';
import { NextApiRequest, NextApiResponse } from 'next';

import dbConnect from '../database/helpers/connect';

type ApiMethodHandlers = {
    [key: string]: () => Promise<void>;
};

export const handleApiMethods = async (
    req: NextApiRequest,
    res: NextApiResponse,
    methodHandlers: ApiMethodHandlers,
): Promise<void> => {
    const { method } = req;
    try {
        if (!method) throw new Error('Method not defined');
        const handler = methodHandlers[method];
        if (!handler) throw new Error('Method not supported');
        await handler();
    } catch (error) {
        /* eslint-disable no-console */
        console.error(error);
        res.status(400).json({ success: false });
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
            res.status(201).json({ doc });
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
            res.status(200).json({ brick: doc });
        },
        DELETE: async () => {
            await dbConnect();
            await model.deleteOne({ _id: id }).orFail();
            res.status(200).json({ success: true });
        },
        ...additionalMethodHandlers,
    });
};
