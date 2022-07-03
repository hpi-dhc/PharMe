import axios from 'axios';
import { Types } from 'mongoose';
import { NextApiHandler } from 'next';

import { handleApiMethods } from '../../../common/api-helpers';
import {
    serverEndpointGuidelines,
    serverEndpointMeds,
    ServerGuidelineOverview,
    ServerMedication,
} from '../../../common/server-types';
import dbConnect from '../../../database/helpers/connect';
import {
    BrickResolver,
    resolveBricks,
} from '../../../database/helpers/resolve-bricks';
import GuidelineAnnotation from '../../../database/models/GuidelineAnnotation';
import MedAnnotation from '../../../database/models/MedAnnotation';
import { ITextBrick } from '../../../database/models/TextBrick';

type PopulatedBricks = ITextBrick<Types.ObjectId>[] | undefined;
const resolve = (resolver: BrickResolver, bricks: PopulatedBricks) =>
    bricks
        ? resolveBricks(resolver, bricks)
              .map(([, text]) => text)
              .filter((text) => text)
              .join(' ')
        : undefined;

const api: NextApiHandler = async (req, res) =>
    handleApiMethods(req, res, {
        PATCH: async () => {
            const [medicationResponse, guidelineResponse] = await Promise.all([
                axios.get<ServerMedication[]>(serverEndpointMeds(), {
                    params: { withGuidelines: true },
                }),
                axios.get<ServerGuidelineOverview[]>(
                    serverEndpointGuidelines(),
                ),
            ]);

            await dbConnect();
            const [medAnnotations, guidelineAnnotations] = await Promise.all([
                await Promise.all(
                    medicationResponse.data.map((medication) =>
                        MedAnnotation!
                            .findMatching(medication)
                            .populate<{
                                drugclass: PopulatedBricks;
                                indication: PopulatedBricks;
                            }>(['drugclass', 'indication'])
                            .lean()
                            .exec(),
                    ),
                ),
                await Promise.all(
                    guidelineResponse.data.map((guideline) =>
                        GuidelineAnnotation!
                            .findMatching(guideline)
                            .populate<{
                                implication: PopulatedBricks;
                                recommendation: PopulatedBricks;
                            }>(['implication', 'recommendation'])
                            .lean()
                            .exec(),
                    ),
                ),
            ]);

            const medPatches = medAnnotations
                .map((annotation, index) => {
                    if (!annotation) return undefined;
                    const resolver: BrickResolver = {
                        from: 'serverMedication',
                        with: medicationResponse.data[index],
                    };
                    return {
                        id: medicationResponse.data[index].id,
                        drugclass: resolve(resolver, annotation.drugclass),
                        indication: resolve(resolver, annotation.indication),
                    };
                })
                .filter((patch) => patch);
            const guidelinePatches = guidelineAnnotations
                .map((annotation, index) => {
                    if (!annotation) return undefined;
                    const resolver: BrickResolver = {
                        from: 'serverGuideline',
                        with: guidelineResponse.data[index],
                    };
                    return {
                        id: guidelineResponse.data[index].id,
                        implication: resolve(resolver, annotation.implication),
                        recommendation: resolve(
                            resolver,
                            annotation.recommendation,
                        ),
                        warningLevel: annotation.warningLevel,
                    };
                })
                .filter((patch) => patch);

            await Promise.all([
                axios.patch(serverEndpointMeds(), medPatches),
                axios.patch(serverEndpointGuidelines(), guidelinePatches),
            ]);

            res.status(204).end();
        },
    });

export default api;
