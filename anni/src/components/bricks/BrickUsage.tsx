import { useSwrFetcher } from '../../common/react-helpers';
import { GetAnnotationsReponse } from '../../pages/api/annotations';
import StatusBadge from '../annotations/StatusBadge';
import GenericError from '../common/indicators/GenericError';
import LoadingSpinner from '../common/indicators/LoadingSpinner';
import TableRow from '../common/interaction/TableRow';
import Explanation from '../common/text/Explanation';

type Props = {
    id: string;
};

const BrickUsageList = ({ id }: Props) => {
    const { data: response, error } = useSwrFetcher<GetAnnotationsReponse>(
        `/api/bricks/${id}`,
    );
    const drugs = response?.data.data.drugs;

    return (
        <div className="space-y-2 pt-4">
            <h2 className="font-bold text-2xl border-t border-black border-opacity-10 pt-3">
                Usage
            </h2>
            <Explanation>
                Check which Annotations are currently set up to use this Brick.
            </Explanation>
            <div className="pt-3">
                {error ? (
                    <GenericError />
                ) : !drugs ? (
                    <LoadingSpinner />
                ) : (
                    drugs?.map((drug) => (
                        <TableRow
                            key={drug._id}
                            link={`/annotations/${drug._id}`}
                        >
                            <div className="flex justify-between">
                                <span className="mr-2">{drug.name}</span>
                                <StatusBadge
                                    curationState={drug.curationState}
                                    staged={drug.isStaged}
                                />
                            </div>
                        </TableRow>
                    ))
                )}
            </div>
        </div>
    );
};

export default BrickUsageList;
