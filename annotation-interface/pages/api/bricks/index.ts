import { NextApiHandler } from 'next';

import dbConnect from '../../../database/connect';
import TextBrick from '../../../database/models/TextBrick';

const brickApi: NextApiHandler = async (req, res) => {
    const { method } = req;
    await dbConnect();

    try {
        switch (method) {
            case 'POST':
                const brick = await TextBrick!.create(req.body);
                res.status(201).json({ brick });
                return;
            default:
                throw new Error();
        }
    } catch (error) {
        res.status(400).json({ success: false });
    }
};

export default brickApi;
