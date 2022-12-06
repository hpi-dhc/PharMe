import axios from 'axios';
import { Types } from 'mongoose';
import { NextApiHandler } from 'next';

import { handleApiMethods } from '../../common/api-helpers';
import {
    CpicRecommendation,
    cpicRecommendationsParams,
    cpicRecommendationsURL,
} from '../../common/cpic-api';
import dbConnect from '../../database/helpers/connect';
import { getDrugsWithContractedGuidelines } from '../../database/helpers/cpic-constructors';
import Drug from '../../database/models/Drug';
import Guideline from '../../database/models/Guideline';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        POST: async () => {
            await dbConnect();
            const [cpicResponse] = await Promise.all([
                axios.get<CpicRecommendation[]>(cpicRecommendationsURL, {
                    params: cpicRecommendationsParams,
                }),
                Guideline!.deleteMany({}),
                Drug!.deleteMany({}),
            ]);
            const recommendations = cpicResponse.data;
            const drugsWithGuidelines =
                getDrugsWithContractedGuidelines(recommendations);

            // could parallelize more here but not worth the added complexity
            // since we don't have too many drugs
            for (const { drug, guidelines } of drugsWithGuidelines) {
                const guidelineIds = (
                    await Promise.all(
                        guidelines.map((guideline) =>
                            Guideline!.create(guideline),
                        ),
                    )
                ).map((guideline) => guideline._id) as Types.ObjectId[];
                drug.guidelines = guidelineIds;
                await Drug!.create(drug);
            }
            return { successStatus: 201 };
        },
    });

export default api;
