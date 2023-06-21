import { CurationState } from '../../database/helpers/annotations';
import Label from '../common/indicators/Label';

type Props = {
    curationState: CurationState;
    staged: boolean;
};

const StatusBadge = ({ curationState, staged }: Props) => (
    <span>
        <Label
            title={`${curationState.curated} of ${curationState.total} curated`}
            dark={curationState.total === curationState.curated}
            gray={curationState.curated > 0}
        />
        {staged && <Label title="Staged" dark />}
    </span>
);

export default StatusBadge;
