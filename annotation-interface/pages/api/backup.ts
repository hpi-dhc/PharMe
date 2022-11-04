import { NextApiHandler } from 'next';

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
                res.status(400).json({
                    success: false,
                    message: 'There is no data to back up.',
                });
                return;
            }
            res.status(200).json({
                success: true,
                data: { bricks, guidelines, medications },
            });
        },
        POST: async () => {
            await dbConnect();
            await Promise.all([
                Medication!.deleteMany({}),
                Guideline!.deleteMany({}),
                TextBrick!.deleteMany({}),
            ]);
            const { bricks, guidelines, medications } = req.body.data;
            await TextBrick!.insertMany(bricks);
            await Guideline!.insertMany(guidelines);
            await Medication!.insertMany(medications);
            res.status(201).json({ success: true });
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
