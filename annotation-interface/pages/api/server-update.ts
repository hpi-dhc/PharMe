import axios from 'axios';
import { NextApiHandler } from 'next';
import { ApiError } from 'next/dist/server/api-utils';

import { handleApiMethods } from '../../common/api-helpers';
import {
    serverEndpointGuidelines,
    serverEndpointInit,
    serverEndpointMeds,
} from '../../common/server-types';

export type FetchDate = Date | null;
export type FetchTarget = 'all' | 'guidelines';
export interface LastUpdatesDto {
    medications: FetchDate;
    guidelines: FetchDate;
}

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        GET: async () => {
            const [medicationsRes, guidelinesRes] = await Promise.all([
                axios.get<FetchDate>(serverEndpointMeds('last_update')),
                axios.get<FetchDate>(serverEndpointGuidelines('last_update')),
            ]);
            const lastUpdates: LastUpdatesDto = {
                medications: medicationsRes.data,
                guidelines: guidelinesRes.data,
            };
            return { successStatus: 200, data: lastUpdates };
        },
        POST: async () => {
            const target = req.body.target as FetchTarget;
            switch (target) {
                case 'all':
                    await axios.post(serverEndpointInit);
                    break;
                case 'guidelines':
                    await axios.post(serverEndpointGuidelines());
                    break;
                default:
                    throw new ApiError(400, 'Unknown target');
            }
            return { successStatus: 201 };
        },
    });

export default api;
