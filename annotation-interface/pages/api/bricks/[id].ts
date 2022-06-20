import { NextApiRequest, NextApiResponse } from 'next';

import dbConnect from '../../../database/connect';
import TextBrick from '../../../database/models/TextBrick';

const brickApi = async (
    req: NextApiRequest,
    res: NextApiResponse,
): Promise<void> => {
    const {
        query: { id },
        method,
    } = req;
    await dbConnect();

    switch (method) {
        case 'PUT':
            try {
                const brick = await TextBrick!
                    .findByIdAndUpdate(id, req.body, {
                        new: true,
                        runValidators: true,
                    })
                    .orFail();
                res.status(200).json({ success: true, data: brick });
            } catch (error) {
                res.status(400).json({ success: false });
            }
            break;

        case 'DELETE':
            try {
                await TextBrick!.deleteOne({ _id: id }).orFail();
                res.status(200).json({ success: true, data: {} });
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
