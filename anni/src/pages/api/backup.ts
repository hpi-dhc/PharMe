import JSZip from 'jszip';
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

            const zip = new JSZip();
            zip.file('backup.json', JSON.stringify(data));
            const base64 = await zip.generateAsync({
                type: 'base64',
                compression: 'DEFLATE',
                compressionOptions: { level: 9 },
            });

            return { successStatus: 200, data: { base64 } };
        },
        POST: async () => {
            const base64: string = req.body.data.base64;
            const zip = new JSZip();
            await zip.loadAsync(base64, {
                base64: true,
            });
            const data: Record<string, object> = JSON.parse(
                await zip.files['backup.json'].async('string'),
            );

            await dbConnect();

            await Promise.all(
                Object.values(mongoose.models).map((model) =>
                    model.deleteMany(),
                ),
            );

            await Promise.all(
                Object.entries(data).map(([name, docs]) =>
                    mongoose.models[name].create(docs, {
                        validateBeforeSave: false,
                    }),
                ),
            );
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
