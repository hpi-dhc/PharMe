import mongoose from 'mongoose';
import { NextApiHandler } from 'next';

import { handleApiMethods } from '../../common/api-helpers';
import dbConnect from '../../database/helpers/connect';

/* eslint-disable @typescript-eslint/no-explicit-any */
const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            await dbConnect();
            const models = Object.entries(mongoose.models);

            const backups = await Promise.all(
                models.map(
                    async ([name, model]): Promise<
                        [string, mongoose.LeanDocument<any>[]]
                    > => [name, await model.find({}).lean().exec()],
                ),
            );

            const data = backups.reduce((total, [name, docs]) => {
                total[name] = docs;
                return total;
            }, {} as Record<string, mongoose.LeanDocument<any>[]>);

            return { successStatus: 200, data };
        },
        POST: async () => {
            await dbConnect();
            return { successStatus: 201 };
        },
    });

export default api;

export const config = {
    api: {
        bodyParser: {
            // TODO: if we need to have more than 4mb we will have to think of
            //       a solution that doesn't use a Next API route
            sizeLimit: '4mb',
        },
    },
};
