import {
    CheckIcon,
    ExclamationIcon,
    UploadIcon,
    XIcon,
} from '@heroicons/react/solid';
import axios from 'axios';
import Link from 'next/link';
import { useState } from 'react';

import { useSwrFetcher } from '../common/react-helpers';
import WithIcon from '../components/common/WithIcon';
import GenericError from '../components/common/indicators/GenericError';
import LoadingSpinner from '../components/common/indicators/LoadingSpinner';
import Button from '../components/common/interaction/Button';
import PageHeading from '../components/common/structure/PageHeading';
import PageOverlay from '../components/common/structure/PageOverlay';
import Emphasis from '../components/common/text/Emphasis';
import Explanation from '../components/common/text/Explanation';
import { GetPublishStatusReponse } from './api/publish';

const Home = () => {
    const [publishVisible, setPublishVisible] = useState(false);
    const { data: response, error } =
        useSwrFetcher<GetPublishStatusReponse>('/api/publish');
    const publishingError = response?.data.data.errorMessage;

    const [loadingState, setLoadingState] = useState<JSX.Element | null>(null);
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
                        onClick={() => {
                            setPublishVisible(false);
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
        <div className="space-y-4">
            <PageHeading title="PharMe's Annotation Interface">
                Welcome to the curator&apos;s interface to PharMe&apos;s
                user-agnostic data: the Annotation Interface aka.{' '}
                <Emphasis>Anni</Emphasis>! PharMe uses{' '}
                <Emphasis>external data</Emphasis> from{' '}
                <a className="underline" href="https://cpicpgx.org">
                    CPIC
                </a>{' '}
                and supplements it with patient-oriented{' '}
                <Emphasis>internal data</Emphasis>. This internal data is
                defined using Anni and referred to as{' '}
                <Link href="/annotations">
                    <a className="underline">Annotations</a>
                </Link>
                .
            </PageHeading>
            <div className="space-y-2">
                <h2 className="font-bold text-2xl">Publishing</h2>
                <Explanation>
                    <p>
                        <Emphasis>Publishing</Emphasis> data refers to the
                        action of making all data marked as{' '}
                        <Emphasis>staged</Emphasis> available to users through
                        PharMe&apos;s app. This is only possible when all staged
                        Annotations are defined in the given language.
                    </p>
                </Explanation>
                <h3 className="font-bold">Current status</h3>
                <div className="flex justify-between items-center">
                    {response ? (
                        publishingError ? (
                            <WithIcon icon={ExclamationIcon} as="p">
                                {publishingError}
                            </WithIcon>
                        ) : (
                            <>
                                <WithIcon icon={CheckIcon} as="p">
                                    Ready to publish.
                                </WithIcon>
                                <Button
                                    icon={UploadIcon}
                                    onClick={() => setPublishVisible(true)}
                                    reverse
                                >
                                    Publish
                                </Button>
                            </>
                        )
                    ) : error ? (
                        <GenericError />
                    ) : (
                        <LoadingSpinner />
                    )}
                </div>
            </div>
            {publishVisible && (
                <PageOverlay
                    hide={() => !loadingState && setPublishVisible(false)}
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
                                    onClick={() => setPublishVisible(false)}
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

export default Home;
