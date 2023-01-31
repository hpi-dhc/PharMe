import StagingToggle, { Props } from './StagingToggle';
import { BackButton } from '../common/interaction/BackButton';

const TopBar = (props: Props) => (
    <div className="flex justify-between">
        <BackButton />
        <StagingToggle {...props} />
    </div>
);

export default TopBar;
