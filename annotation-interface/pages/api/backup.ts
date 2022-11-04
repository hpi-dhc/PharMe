import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../common/api-helpers';
import dbConnect from '../../database/helpers/connect';
import Guideline from '../../database/models/Guideline';
import Medication from '../../database/models/Medication';
import TextBrick from '../../database/models/TextBrick';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            await dbConnect();
            const [bricks, guidelines, medications] = await Promise.all([
                TextBrick!.find({}).lean().exec(),
                Guideline!.find({}).lean().exec(),
                Medication!.find({}).lean().exec(),
            ]);
            if (guidelines.length + bricks.length + medications.length === 0) {
                throw new ApiError(404, 'There is no data to back up');
            }
            return {
                successStatus: 200,
                data: { bricks, guidelines, medications },
            };
        },
        POST: async () => {
            await dbConnect();
            await Promise.all([
                Medication!.deleteMany({}).orFail(),
                Guideline!.deleteMany({}).orFail(),
                TextBrick!.deleteMany({}).orFail(),
            ]);
            const { bricks, guidelines, medications } = req.body.data;
            await TextBrick!.insertMany(bricks);
            await Guideline!.insertMany(guidelines);
            await Medication!.insertMany(medications);
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
