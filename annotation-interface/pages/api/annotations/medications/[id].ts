import axios from 'axios';
import { NextApiHandler } from 'next';

import { updateDeleteApi } from '../../../../common/api-helpers';
import { ServerMedication } from '../../../../common/server-types';
import MedAnnotation, {
    IMedAnnotation,
} from '../../../../database/models/MedAnnotation';

export interface GetMedicationDto {
    serverMedication: ServerMedication;
    annotation: IMedAnnotation<string, string> | null;
}

const api: NextApiHandler = async (req, res) =>
    await updateDeleteApi(MedAnnotation!, req, res, {
        GET: async () => {
            const {
                query: { id },
            } = req;
            const getResponse = await axios.get<ServerMedication>(
                `http://${process.env.AS_API}/medications/${id}`,
            );
            const serverMedication = getResponse.data;
            const response: GetMedicationDto = {
                serverMedication,
                annotation: null,
            };
            const annotation = await MedAnnotation!
                .findOne({
                    medicationRxCUI: serverMedication.rxcui,
                })
                .lean()
                .exec();
            if (annotation) {
                response.annotation = {
                    ...annotation,
                    drugclass: annotation!.drugclass?.map((id) =>
                        id.toString(),
                    ),
                    indication: annotation!.indication?.map((id) =>
                        id.toString(),
                    ),
                    _id: annotation!._id!.toString(),
                };
            }
            res.status(200).json(response);
        },
    });

export default api;
