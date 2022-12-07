import { BadgeCheckIcon as BadgeOutlineIcon } from '@heroicons/react/outline';
import { BadgeCheckIcon as BadgeSolidIcon } from '@heroicons/react/solid';
import axios from 'axios';
import { mutate } from 'swr';

import { useSwrFetcher } from '../../common/react-helpers';
import { useGlobalContext } from '../../contexts/global';
import {
    GetStagingResponse,
    UpdateStagingBody,
} from '../../pages/api/annotations/staging/[id]';
import WithIcon from '../common/WithIcon';

export type Props = {
    api: string;
    isStaged: boolean | undefined;
};

export const useStagingApi = (id: string) => {
    const api = `/api/annotations/staging/${id}`;
    const { data: response } = useSwrFetcher<GetStagingResponse>(api);
    return { api, isStaged: response?.data.data.isStaged };
};

const StagingToggle = ({ api, isStaged }: Props) => {
    const { reviewMode } = useGlobalContext();
    return (
        <WithIcon
            icon={isStaged ? BadgeSolidIcon : BadgeOutlineIcon}
            as="button"
            className={
                'text-s px-2 py-1 rounded-md whitespace-nowrap' +
                (isStaged
                    ? ` overflow-clip bg-black bg-opacity-80 text-white ${
                          reviewMode ? 'cursor-default' : 'hover:bg-opacity-60'
                      } `
                    : ` border border-black border-opacity-20 ${
                          reviewMode ? 'cursor-default' : 'hover:bg-neutral-100'
                      } `)
            }
            reverse
            onClick={async () => {
                if (reviewMode) return;
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
