import axios from 'axios';
import { NextApiHandler } from 'next';

import { handleApiMethods } from '../../../../common/api-helpers';
import { ServerMedication } from '../../../../common/server-types';
import dbConnect from '../../../../database/helpers/connect';
import MedAnnotation, {
    IMedAnnotation,
} from '../../../../database/models/MedAnnotation';

export interface GetMedicationDto {
    serverMedication: ServerMedication;
    annotation: IMedAnnotation<string, string> | null;
}

export interface PatchMedicationDto {
    serverData: Partial<ServerMedication>;
    annotation: Partial<IMedAnnotation<string, string>>;
}

const api: NextApiHandler = async (req, res) => {
    const {
        query: { id },
    } = req;
    const getResponse = await axios.get<ServerMedication>(
        `http://${process.env.AS_API}/medications/${id}`,
    );
    const serverMedication = getResponse.data;

    await dbConnect();
    const findResult = await MedAnnotation!
        .findOne({ medicationRxCUI: serverMedication.rxcui })
        .lean()
        .exec();
    let annotation: IMedAnnotation<string, string> | null = findResult
        ? {
              ...findResult,
              drugclass: findResult!.drugclass?.map((id) => id.toString()),
              indication: findResult!.indication?.map((id) => id.toString()),
              _id: findResult!._id!.toString(),
          }
        : null;

    await handleApiMethods(req, res, {
        GET: async () => {
            const response: GetMedicationDto = {
                serverMedication,
                annotation,
            };
            res.status(200).json(response);
        },
        PATCH: async () => {
            const { annotation: patch } = req.body as PatchMedicationDto;
            if (!annotation && (patch.drugclass || patch.indication)) {
                annotation = {
                    medicationRxCUI: serverMedication.rxcui,
                    medicationName: serverMedication.name,
                    ...patch,
                };
                await MedAnnotation!.create(annotation);
            } else if (annotation) {
                annotation = { ...annotation, ...patch };
                if (annotation.drugclass || annotation.indication) {
                    await MedAnnotation!
                        .findByIdAndUpdate(annotation._id!, annotation, {
                            runValidators: true,
                        })
                        .orFail();
                } else {
                    await MedAnnotation!
                        .findByIdAndDelete(annotation._id!)
                        .orFail();
                }
            }
            res.status(204).end();
        },
    });
};
export default api;
