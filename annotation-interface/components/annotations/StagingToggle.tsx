import { BadgeCheckIcon as BadgeOutlineIcon } from '@heroicons/react/outline';
import { BadgeCheckIcon as BadgeSolidIcon } from '@heroicons/react/solid';
import axios from 'axios';
import { mutate } from 'swr';

import { useSwrFetcher } from '../../common/react-helpers';
import {
    GetStagingResponse,
    UpdateStagingBody,
} from '../../pages/api/annotations/staging/[id]';
import WithIcon from '../common/WithIcon';

export type Props = {
    _id: string;
};

const StagingToggle = ({ _id }: Props) => {
    const api = `/api/annotations/staging/${_id}`;
    const { data: response } = useSwrFetcher<GetStagingResponse>(api);
    const isStaged = response?.data.data.isStaged;
    return (
        <WithIcon
            icon={isStaged ? BadgeSolidIcon : BadgeOutlineIcon}
            as="button"
            className={
                'text-s px-2 py-1 rounded-md whitespace-nowrap' +
                (isStaged
                    ? ' overflow-clip bg-black bg-opacity-80 text-white hover:bg-opacity-60 '
                    : ' border border-black border-opacity-20 hover:bg-neutral-100 ')
            }
            reverse
            onClick={async () => {
                const patch: UpdateStagingBody = {
                    isStaged: isStaged ? 'false' : 'true',
                };
                await axios.patch(api, patch);
                await mutate(api);
            }}
        >
            {isStaged ? 'Staged' : 'Not staged'}
        </WithIcon>
    );
};

export default StagingToggle;
