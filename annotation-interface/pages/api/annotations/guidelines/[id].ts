import axios from 'axios';
import { NextApiHandler } from 'next';

import { handleApiMethods } from '../../../../common/api-helpers';
import {
    serverEndpointGuidelines,
    ServerGuideline,
} from '../../../../common/server-types';
import dbConnect from '../../../../database/helpers/connect';
import GuidelineAnnotation, {
    IGuidelineAnnotation,
} from '../../../../database/models/GuidelineAnnotation';

export interface GetGuidelineDto {
    serverGuideline: ServerGuideline;
    annotation: IGuidelineAnnotation<string, string> | null;
}

export interface PatchGuidelineDto {
    serverData: Partial<ServerGuideline>;
    annotation: Partial<IGuidelineAnnotation<string, string>>;
}

const api: NextApiHandler = async (req, res) => {
    const {
        query: { id },
    } = req;
    const getResponse = await axios.get<ServerGuideline>(
        serverEndpointGuidelines(id as string),
    );
    const serverGuideline = getResponse.data;

    await dbConnect();
    const findResult = await GuidelineAnnotation!
        .findMatching(serverGuideline)
        .lean()
        .exec();
    let annotation: IGuidelineAnnotation<string, string> | null = findResult
        ? {
              ...findResult,
              recommendation: findResult!.recommendation?.map((id) =>
                  id.toString(),
              ),
              implication: findResult!.implication?.map((id) => id.toString()),
              _id: findResult!._id!.toString(),
          }
        : null;

    await handleApiMethods(req, res, {
        GET: async () => {
            const response: GetGuidelineDto = { serverGuideline, annotation };
            return { successStatus: 200, data: response };
        },
        PATCH: async () => {
            const { serverData: serverPatch, annotation: patch } =
                req.body as PatchGuidelineDto;
            await axios.patch(serverEndpointGuidelines(), [
                { id: serverGuideline.id, ...serverPatch },
            ]);

            if (
                !annotation &&
                (patch.implication ||
                    patch.recommendation ||
                    patch.warningLevel)
            ) {
                annotation = {
                    medicationRxCUI: serverGuideline.medication.rxcui,
                    medicationName: serverGuideline.medication.name,
                    geneSymbol: serverGuideline.phenotype.geneSymbol.name,
                    geneResult: serverGuideline.phenotype.geneResult.name,
                    ...patch,
                };
                await GuidelineAnnotation!.create(annotation);
            } else if (annotation) {
                annotation = { ...annotation, ...patch };
                if (
                    annotation.implication ||
                    annotation.recommendation ||
                    patch.warningLevel
                ) {
                    await GuidelineAnnotation!
                        .findByIdAndUpdate(annotation._id!, annotation, {
                            runValidators: true,
                        })
                        .orFail();
                } else {
                    await GuidelineAnnotation!
                        .findByIdAndDelete(annotation._id!)
                        .orFail();
                }
            }
            return { successStatus: 204 };
        },
    });
};

export default api;
