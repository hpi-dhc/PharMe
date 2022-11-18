import { ChevronLeftIcon } from '@heroicons/react/outline';
import { useRouter } from 'next/router';

import WithIcon from '../WithIcon';

export const BackButton = () => {
    const router = useRouter();
    return (
        <button onClick={() => router.back()}>
            <a className="underline">
                <WithIcon icon={ChevronLeftIcon}>Back</WithIcon>
            </a>
        </button>
    );
};
