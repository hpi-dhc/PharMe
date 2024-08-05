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
    DrugWithGuidelines,
    getAdditionalDrugs,
    getDrugsWithGuidelines,
} from '../../database/helpers/cpic-constructors';
import Drug from '../../database/models/Drug';
import Guideline from '../../database/models/Guideline';

const getCpicData = async (): Promise<DrugWithGuidelines[]> => {
    const response = await axios.get<CpicRecommendation[]>(
        cpicRecommendationsURL,
        {
            params: cpicRecommendationsParams,
        },
    );
    const recommendations = response.data;
    return getDrugsWithGuidelines(recommendations, 'CPIC');
};

type GHContentResponse = {
    name: string;
    download_url: string;
}[];

const getAdditionalData = async (): Promise<DrugWithGuidelines[][]> => {
    if (!process.env.ADD_ANNOTATIONS_REPO) return [];

    const gh = axios.create({
        headers: process.env.GITHUB_OAUTH
            ? {
                  Authorization: `Bearer ${process.env.GITHUB_OAUTH}`,
              }
            : {},
    });
    const contents = await gh.get<GHContentResponse>(
        `https://api.github.com/repos/${process.env.ADD_ANNOTATIONS_REPO}/contents/annotations`,
    );
    return await Promise.all(
        contents.data
            .filter((item) => item.name.endsWith('.json'))
            .map(async (item) => {
                const response = await gh.get<CpicRecommendation[]>(
                    item.download_url,
                );
                const source = item.name.replace(/\.json$/, '');
                if (source == 'additional_drugs') {
                    return getAdditionalDrugs(response.data);
                }
                return getDrugsWithGuidelines(response.data, source);
            }),
    );
};

const api: NextApiHandler = async (req, res) =>
    await handleApiMethods(req, res, {
        POST: async () => {
            await dbConnect();

            await Promise.all([
                Guideline!.deleteMany({}),
                Drug!.deleteMany({}),
            ]);

            const drugsWithGuidelines = await getCpicData();
            for (const additional of await getAdditionalData()) {
                drugsWithGuidelines.push(...additional);
            }

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
