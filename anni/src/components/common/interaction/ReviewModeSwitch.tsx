import { Switch } from '@headlessui/react';

import { useGlobalContext } from '../../../contexts/global';
import Tooltip from '../indicators/Tooltip';

const ReviewModeSwitch = () => {
    const { reviewMode, setReviewMode } = useGlobalContext();

    return (
        <Tooltip
            hint="Review mode allows you to stage and unstage Annotations while disabling all other edits."
            expandUpwards
        >
            <div className="flex justify-between">
                <p className="mr-6">Review mode</p>
                <div>
                    <Switch
                        checked={reviewMode}
                        onChange={setReviewMode}
                        className={`${
                            reviewMode ? 'bg-neutral-800' : 'bg-neutral-200'
                        } relative inline-flex h-[1.5rem] w-[2.4rem] items-center rounded-full`}
                    >
                        <span className="sr-only">Enable review mode</span>
                        <span
                            className={`${
                                reviewMode
                                    ? 'translate-x-[1rem]'
                                    : 'translate-x-[0.1rem]'
                            } inline-block h-[1.3rem] w-[1.3rem] transform rounded-full bg-white transition`}
                        />
                    </Switch>
                </div>
            </div>
        </Tooltip>
    );
};

export default ReviewModeSwitch;
