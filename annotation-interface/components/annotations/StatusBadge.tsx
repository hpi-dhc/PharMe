import Label from '../common/indicators/Label';

type Props = {
    badge: number;
    staged: boolean;
};

const StatusBadge = ({ badge, staged }: Props) => (
    <span>
        {badge > 0 && <Label title={`${badge} missing`} />}
        {staged && <Label title="Staged" dark />}
    </span>
);

export default StatusBadge;
