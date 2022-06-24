import { ExclamationIcon } from '@heroicons/react/solid';

import WithIcon from '../common/WithIcon';

const AnnotationMissing = () => (
    <WithIcon icon={ExclamationIcon}>Not Set</WithIcon>
);

const Annotation = ({
    title,
    body,
}: {
    title: string;
    body: string | null;
}) => (
    <div className="space-y-2">
        <h2 className="font-bold">{title}</h2>
        <p>{body ?? <AnnotationMissing />}</p>
    </div>
);

export default Annotation;
