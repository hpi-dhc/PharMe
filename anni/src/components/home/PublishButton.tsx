import { CheckIcon, UploadIcon, XIcon } from '@heroicons/react/solid';
import axios from 'axios';
import { useState } from 'react';
import { useSWRConfig } from 'swr';

import WithIcon from '../common/WithIcon';
import GenericError from '../common/indicators/GenericError';
import LoadingSpinner from '../common/indicators/LoadingSpinner';
import Button from '../common/interaction/Button';
import PageOverlay from '../common/structure/PageOverlay';

const PublishButton = () => {
    const [panelVisible, setPanelVisible] = useState(false);
    const [loadingState, setLoadingState] = useState<JSX.Element | null>(null);
    const { mutate } = useSWRConfig();
    const publish = async () => {
        setLoadingState(null);
        try {
            setLoadingState(
                <div className="space-y-2">
                    <LoadingSpinner dark />
                    <p>Publishing data ...</p>
                </div>,
            );
            await axios.post('/api/publish');
            setLoadingState(
                <>
                    <WithIcon icon={CheckIcon}>Success</WithIcon>
                    <Button
                        onClick={async () => {
                            await mutate('/api/v1/version');
                            setPanelVisible(false);
                            setLoadingState(null);
                        }}
                        dark
                    >
                        Done
                    </Button>
                </>,
            );
        } catch {
            setLoadingState(<GenericError />);
        }
    };

    return (
        <div>
            <Button
                icon={UploadIcon}
                onClick={() => setPanelVisible(true)}
                reverse
            >
                Publish
            </Button>
            {panelVisible && (
                <PageOverlay
                    hide={() => !loadingState && setPanelVisible(false)}
                    heading="Publish data"
                    explanation="Are you sure? This action will have an immediate effect on users and cannot be directly undone."
                >
                    <div className="flex justify-center space-x-12">
                        {!loadingState ? (
                            <>
                                <Button
                                    onClick={publish}
                                    icon={UploadIcon}
                                    dark
                                >
                                    Publish now
                                </Button>
                                <Button
                                    onClick={() => setPanelVisible(false)}
                                    icon={XIcon}
                                    dark
                                >
                                    Cancel
                                </Button>
                            </>
                        ) : (
                            loadingState
                        )}
                    </div>
                </PageOverlay>
            )}
        </div>
    );
};

export default PublishButton;
