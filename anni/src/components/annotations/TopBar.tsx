import { BackButton } from '../common/interaction/BackButton';
import StagingToggle, { Props } from './StagingToggle';

const TopBar = (props: Props) => (
    <div className="flex justify-between">
        <BackButton />
        <StagingToggle {...props} />
    </div>
);

export default TopBar;
