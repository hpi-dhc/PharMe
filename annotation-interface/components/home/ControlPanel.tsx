import { CloudDownloadIcon } from '@heroicons/react/solid';
import axios from 'axios';
import { useState } from 'react';
import { useSWRConfig } from 'swr';

import { FetchTarget, LastUpdatesDto } from '../../pages/api/server-update';
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
        <div
            className="fixed top-0 left-0 w-full h-full bg-black bg-opacity-80 text-white text-opacity-80 backdrop-blur-sm"
            onClick={() => !isLoading && hide()}
        >
            <div
                className="max-w-screen-md m-auto py-20 space-y-6"
                onClick={(e) => e.stopPropagation()}
            >
                <h2 className="text-2xl font-bold">Fetch new data</h2>
                <p>
                    Note that fetching data may take up to ten minutes and users
                    may experience undefined behavior during this time period.
                    Use with caution and keep this page open while fetching
                    data.
                </p>
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
                                {updates?.medications ? 'Update' : 'Fetch'} all
                                data
                            </WithIcon>
                        </div>
                        {updates?.medications && (
                            <div>
                                <WithIcon
                                    as="button"
                                    icon={CloudDownloadIcon}
                                    onClick={() =>
                                        fetchServerData('guidelines')
                                    }
                                >
                                    {updates?.guidelines ? 'Update' : 'Fetch'}{' '}
                                    CPIC guidelines
                                </WithIcon>
                            </div>
                        )}
                    </>
                )}
            </div>
        </div>
    );
};

export default ControlPanel;
