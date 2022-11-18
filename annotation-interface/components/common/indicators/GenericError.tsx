import { EmojiSadIcon } from '@heroicons/react/outline';

import WithIcon from '../WithIcon';

function GenericError() {
    return (
        <div>
            <div className="flex justify-center">
                <WithIcon icon={EmojiSadIcon}>
                    There has been a server error! If the problem persists,
                    please contact a developer for help.
                </WithIcon>
            </div>
        </div>
    );
}

export default GenericError;
