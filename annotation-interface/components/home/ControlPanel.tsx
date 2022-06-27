import { CloudDownloadIcon } from '@heroicons/react/solid';
import axios from 'axios';
import { useState } from 'react';
import { useSWRConfig } from 'swr';

import { FetchTarget, LastUpdatesDto } from '../../pages/api/server-update';
import PageOverlay from '../common/PageOverlay';
import WithIcon from '../common/WithIcon';

type Props = {
    updates: LastUpdatesDto | undefined;
    hide: () => void;
};

const ControlPanel = ({ updates, hide }: Props) => {
    const { mutate } = useSWRConfig();
    const [isLoading, setIsLoading] = useState(false);
    const [message, setMessage] = useState('');
    const fetchServerData = async (target: FetchTarget) => {
        setIsLoading(true);
        setMessage('');
        try {
            await axios.post('/api/server-update', { target });
            setMessage('Success!');
        } catch {
            setMessage(
                `An unexpected error occured. Try again or contact the Annotation Server's maintainer`,
            );
        }
        mutate('/api/server-update');
        setIsLoading(false);
    };
    return (
        <PageOverlay
            hide={() => !isLoading && hide()}
            heading="Fetch new data"
            explanation="Note that fetching data may take up to ten minutes and users may experience undefined behavior during this time period. Use with caution and keep this page open while fetching data."
            className="space-y-6"
        >
            <p>{message}</p>
            {isLoading ? (
                <div className="flex justify-center">
                    <div className="relative">
                        <WithIcon
                            icon={CloudDownloadIcon}
                            className="absolute animate-ping top-0 left-0"
                        />
                        <WithIcon icon={CloudDownloadIcon}>
                            Fetching data ...
                        </WithIcon>
                    </div>
                </div>
            ) : (
                <>
                    <div>
                        <WithIcon
                            as="button"
                            icon={CloudDownloadIcon}
                            onClick={() => fetchServerData('all')}
                        >
                            {updates?.medications ? 'Update' : 'Fetch'} all data
                        </WithIcon>
                    </div>
                    {updates?.medications && (
                        <div>
                            <WithIcon
                                as="button"
                                icon={CloudDownloadIcon}
                                onClick={() => fetchServerData('guidelines')}
                            >
                                {updates?.guidelines ? 'Update' : 'Fetch'} CPIC
                                guidelines
                            </WithIcon>
                        </div>
                    )}
                </>
            )}
        </PageOverlay>
    );
};

export default ControlPanel;
