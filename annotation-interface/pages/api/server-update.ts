import axios from 'axios';
import { NextApiHandler } from 'next';

export type FetchDate = Date | null;
export interface LastUpdatesDto {
    medications: FetchDate;
    guidelines: FetchDate;
}

const serverUpdateApi: NextApiHandler = async (req, res) => {
    const { method } = req;
    try {
        switch (method) {
            case 'GET':
                const [medicationsRes, guidelinesRes] = await Promise.all([
                    axios.get<FetchDate>(
                        `http://${process.env.AS_API}/medications/last_update`,
                    ),
                    axios.get<FetchDate>(
                        `http://${process.env.AS_API}/guidelines/last_update`,
                    ),
                ]);
                const lastUpdates: LastUpdatesDto = {
                    medications: medicationsRes.data,
                    guidelines: guidelinesRes.data,
                };
                res.status(200).json(lastUpdates);
                return;
            default:
                throw new Error();
        }
    } catch {
        res.status(400).json({ success: false });
    }
};

export default serverUpdateApi;
