import Label from '../common/indicators/Label';

type Props = {
    badge: number;
};

const StatusBadge = ({ badge }: Props) =>
    badge > 0 ? <Label title={`${badge} missing`} /> : <></>;

export default StatusBadge;
