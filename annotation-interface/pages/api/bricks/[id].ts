import { NextApiHandler } from 'next';

import dbConnect from '../../../database/helpers/connect';
import TextBrick from '../../../database/models/TextBrick';

const brickApi: NextApiHandler = async (req, res) => {
    const {
        query: { id },
        method,
    } = req;
    await dbConnect();

    try {
        switch (method) {
            case 'PUT':
                const brick = await TextBrick!
                    .findByIdAndUpdate(id, req.body, {
                        new: true,
                        runValidators: true,
                    })
                    .orFail();
                res.status(200).json({ brick });
                return;
            case 'DELETE':
                await TextBrick!.deleteOne({ _id: id }).orFail();
                res.status(200).json({ success: true });
                return;
            default:
                throw new Error();
        }
    } catch {
        res.status(400).json({ success: false });
    }
};

export default brickApi;
