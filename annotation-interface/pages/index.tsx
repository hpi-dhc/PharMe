import { CloudDownloadIcon, ExclamationIcon } from '@heroicons/react/solid';
import axios from 'axios';
import dayjs from 'dayjs';
import LocalizedFormat from 'dayjs/plugin/localizedFormat';
import RelativeTime from 'dayjs/plugin/relativeTime';
import { useState } from 'react';
import useSWR from 'swr';

import PageHeading from '../components/common/PageHeading';
import WithIcon from '../components/common/WithIcon';
import ControlPanel from '../components/home/ControlPanel';
import { LastUpdatesDto } from './api/server-update';

dayjs.extend(RelativeTime);
dayjs.extend(LocalizedFormat);

const fetchLastUpdateDates = async (url: string) =>
    await axios.get<LastUpdatesDto>(url);

const dateDisplay = (
    lastUpdates: LastUpdatesDto | undefined,
    key: keyof LastUpdatesDto,
) => {
    if (!lastUpdates) return null;
    const date = lastUpdates[key];
    if (!date) return <WithIcon icon={ExclamationIcon}>missing</WithIcon>;
    return (
        <p
            data-bs-toggle="tooltip"
            data-bs-placement="bottom"
            title={dayjs(date).format('lll')}
        >
            Last updated {dayjs(date).fromNow()}
        </p>
    );
};

const Home = () => {
    const { data: updatesResponse, error } = useSWR(
        '/api/server-update',
        fetchLastUpdateDates,
    );
    const lastUpdates = updatesResponse?.data;
    const [controlVisible, setControlVisible] = useState(false);
    return (
        <>
            <PageHeading title="PharMe's Annotation Interface">
                Welcome to the curator&apos;s interface to the{' '}
                <span className="italic">Annotation Server</span>: PharMe&apos;s
                hub for all user-agnostic data. PharMe uses{' '}
                <span className="italic">external data</span> from{' '}
                <a className="underline" href="https://go.drugbank.com">
                    DrugBank
                </a>{' '}
                and{' '}
                <a className="underline" href="https://cpicpgx.org">
                    CPIC
                </a>{' '}
                as well as <span className="italic">internal data</span> defined
                by{' '}
                <a className="underline" href="https://cpicpgx.org">
                    Annotations
                </a>
                .
            </PageHeading>

            <div className="pb-2 border-b border-black border-opacity-10 flex justify-between">
                <h2 className="font-bold">External data status</h2>
                {!error && (
                    <WithIcon
                        as="button"
                        icon={CloudDownloadIcon}
                        reverse
                        onClick={() => setControlVisible(true)}
                    >
                        Fetch new data
                    </WithIcon>
                )}
            </div>
            {error ? (
                <WithIcon as="p" icon={ExclamationIcon} className="p-2">
                    Unable to connect to Annotation Server.
                </WithIcon>
            ) : (
                <>
                    <div className="p-2 flex justify-between">
                        <p>DrugBank: drug names, synonyms, descriptions</p>
                        {dateDisplay(lastUpdates, 'medications')}
                    </div>
                    <div className="p-2 flex justify-between">
                        <p>CPIC: PGx guidelines</p>
                        {dateDisplay(lastUpdates, 'guidelines')}
                    </div>
                </>
            )}
            {controlVisible && (
                <ControlPanel
                    updates={lastUpdates}
                    hide={() => setControlVisible(false)}
                />
            )}
        </>
    );
};

export default Home;
