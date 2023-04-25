import { useSwrFetcher } from '../../common/react-helpers';
import { guidelineDescription } from '../../database/helpers/guideline-data';
import { GetBrickUsageReponse } from '../../pages/api/bricks/[id]';
import StatusBadge from '../annotations/StatusBadge';
import GenericError from '../common/indicators/GenericError';
import LoadingSpinner from '../common/indicators/LoadingSpinner';
import TableRow from '../common/interaction/TableRow';
import Explanation from '../common/text/Explanation';

type Props = {
    id: string;
};

const BrickUsageList = ({ id }: Props) => {
    const { data: response, error } = useSwrFetcher<GetBrickUsageReponse>(
        `/api/bricks/${id}`,
    );
    const data = response?.data.data;

    return (
        <div className="space-y-2 pt-4">
            <h2 className="font-bold text-2xl border-t border-black border-opacity-10 pt-3">
                Usage
            </h2>
            <Explanation>
                Check which Annotations are currently set up to use this Brick.
            </Explanation>
            <div>
                {error ? (
                    <GenericError />
                ) : !data ? (
                    <LoadingSpinner />
                ) : (
                    <>
                        {data?.drugs.length > 0 && (
                            <>
                                <h3 className="font-bold text-xl pt-3">
                                    Drugs
                                </h3>
                                {data?.drugs?.map((drug) => (
                                    <TableRow
                                        key={drug._id}
                                        link={`/annotations/${drug._id}`}
                                    >
                                        <div className="flex justify-between">
                                            <span className="mr-2">
                                                {drug.name}
                                            </span>
                                            <StatusBadge
                                                curationState={
                                                    drug.curationState
                                                }
                                                staged={drug.isStaged}
                                            />
                                        </div>
                                    </TableRow>
                                ))}
                            </>
                        )}
                        {data?.guidelines.length > 0 && (
                            <>
                                <h3 className="font-bold text-xl pt-3">
                                    Guidelines
                                </h3>
                                {data?.guidelines?.map((guideline) => (
                                    <TableRow
                                        key={guideline._id}
                                        link={`/annotations/${guideline.drug._id}/${guideline._id}`}
                                    >
                                        <div className="flex justify-between">
                                            <span className="mr-2">
                                                <p className="font-bold">
                                                    Drug: {guideline.drug.name}
                                                </p>
                                                {guidelineDescription(
                                                    guideline,
                                                ).map((phenotype, index) => (
                                                    <p key={index}>
                                                        <span className="font-bold mr-2">
                                                            {phenotype.gene}
                                                        </span>
                                                        {phenotype.description}
                                                    </p>
                                                ))}
                                            </span>
                                            <StatusBadge
                                                curationState={
                                                    guideline.curationState
                                                }
                                                staged={guideline.isStaged}
                                            />
                                        </div>
                                    </TableRow>
                                ))}
                            </>
                        )}
                    </>
                )}
            </div>
        </div>
    );
};

export default BrickUsageList;
