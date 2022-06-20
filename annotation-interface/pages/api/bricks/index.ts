import { NextApiRequest, NextApiResponse } from 'next';

import dbConnect from '../../../database/connect';
import TextBrick from '../../../database/models/TextBrick';

const brickApi = async (
    req: NextApiRequest,
    res: NextApiResponse,
): Promise<void> => {
    const { method } = req;
    await dbConnect();

    switch (method) {
        case 'POST':
            try {
                const brick = await TextBrick!.create(req.body);
                res.status(201).json({ success: true, data: brick });
            } catch (error) {
                res.status(400).json({ success: false });
            }
            break;
        default:
            res.status(400).json({ success: false });
            break;
    }
};

export default brickApi;
