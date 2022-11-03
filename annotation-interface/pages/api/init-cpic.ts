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
import {
    guidelineFromRecommendation,
    medicationFromRecommendation,
} from '../../database/helpers/cpic-constructors';
import Guideline from '../../database/models/Guideline';
import Medication, { ILeanMedication } from '../../database/models/Medication';

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        POST: async () => {
            await dbConnect();
            const [cpicResponse] = await Promise.all([
                axios.get<CpicRecommendation[]>(cpicRecommendationsURL, {
                    params: cpicRecommendationsParams,
                }),
                Guideline!.deleteMany({}),
                Medication!.deleteMany({}),
            ]);
            const cpicRecommendations = cpicResponse.data;

            const guidelineIds = (
                await Promise.all(
                    cpicRecommendations.map((recommendation) =>
                        Guideline!.create(
                            guidelineFromRecommendation(recommendation),
                        ),
                    ),
                )
            ).map((guideline) => guideline._id) as Types.ObjectId[];

            const medicationMap = new Map<
                string,
                ILeanMedication<Types.ObjectId, Types.ObjectId>
            >();
            cpicRecommendations.forEach((recommendation, index) => {
                const id = recommendation.drugid;
                const guidelineId = guidelineIds[index];
                if (medicationMap.has(id)) {
                    medicationMap.get(id)!.guidelines.push(guidelineId);
                } else {
                    const medication =
                        medicationFromRecommendation(recommendation);
                    medication.guidelines = [guidelineId];
                    medicationMap.set(id, medication);
                }
            });
            await Promise.all(
                Array.from(medicationMap.values()).map((medication) =>
                    Medication!.create(medication),
                ),
            );

            res.status(201).json({ success: true });
        },
    });

export default api;
