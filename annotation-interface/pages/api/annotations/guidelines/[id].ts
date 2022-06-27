import axios from 'axios';
import { NextApiHandler } from 'next';

import { updateDeleteApi } from '../../../../common/api-helpers';
import { ServerGuideline } from '../../../../common/server-types';
import GuidelineAnnotation, {
    IGuidelineAnnotation,
} from '../../../../database/models/GuidelineAnnotation';

export interface GetGuidelineDto {
    serverGuideline: ServerGuideline;
    annotation: IGuidelineAnnotation<string, string> | null;
}

const api: NextApiHandler = async (req, res) =>
    await updateDeleteApi(GuidelineAnnotation!, req, res, {
        GET: async () => {
            const {
                query: { id },
            } = req;
            const getResponse = await axios.get<ServerGuideline>(
                `http://${process.env.AS_API}/guidelines/${id}`,
            );
            const serverGuideline = getResponse.data;
            const response: GetGuidelineDto = {
                serverGuideline,
                annotation: null,
            };
            const annotation = await GuidelineAnnotation!
                .findOne({
                    medicationRxCUI: serverGuideline.medication.rxcui,
                    geneSymbol: serverGuideline.phenotype.geneSymbol.name,
                    geneResult: serverGuideline.phenotype.geneResult.name,
                })
                .lean()
                .exec();
            if (annotation) {
                response.annotation = {
                    ...annotation,
                    recommendation: annotation!.recommendation?.map((id) =>
                        id.toString(),
                    ),
                    implication: annotation!.implication?.map((id) =>
                        id.toString(),
                    ),
                    _id: annotation!._id!.toString(),
                };
            }
            res.status(200).json(response);
        },
    });

export default api;
