import { CheckIcon, ExclamationIcon } from '@heroicons/react/solid';
import Link from 'next/link';

import { useSwrFetcher } from '../common/react-helpers';
import WithIcon from '../components/common/WithIcon';
import GenericError from '../components/common/indicators/GenericError';
import LoadingSpinner from '../components/common/indicators/LoadingSpinner';
import PageHeading from '../components/common/structure/PageHeading';
import Emphasis from '../components/common/text/Emphasis';
import Explanation from '../components/common/text/Explanation';
import PublishButton from '../components/home/PublishButton';
import { GetPublishStatusReponse } from './api/publish';
import { GetCurrentVersionResponse } from './api/v1/version';

const Home = () => {
    const { data: currentVersionResponse, error: currentVersionError } =
        useSwrFetcher<GetCurrentVersionResponse>('/api/v1/version');
    const currentVersion = currentVersionResponse?.data.data.version;

    const { data: isPublishableResponse, error: isPublishableError } =
        useSwrFetcher<GetPublishStatusReponse>('/api/publish');
    const publishingError = isPublishableResponse?.data.data.errorMessage;

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
                {currentVersionError ? (
                    <p>There is currently no version published.</p>
                ) : currentVersion ? (
                    <p>
                        Version {currentVersion} is published and available to
                        users.
                    </p>
                ) : (
                    <LoadingSpinner />
                )}
                <h3 className="font-bold">Publish new version</h3>
                {isPublishableError ? (
                    <GenericError />
                ) : isPublishableResponse ? (
                    <div className="flex justify-between items-center">
                        {publishingError ? (
                            <WithIcon icon={ExclamationIcon} as="p">
                                {publishingError}
                            </WithIcon>
                        ) : (
                            <>
                                <WithIcon icon={CheckIcon} as="p">
                                    Ready to publish.
                                </WithIcon>
                                <PublishButton />
                            </>
                        )}
                    </div>
                ) : (
                    <LoadingSpinner />
                )}
            </div>
        </div>
    );
};

export default Home;
