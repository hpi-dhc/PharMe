import { ServerGuideline } from '../../common/server-types';

const CpicSection = ({
    title,
    content,
}: {
    title: string;
    content: string;
}) => (
    <p>
        <span className="font-bold uppercase tracking-tighter mr-2">
            {title}
        </span>
        {content}
    </p>
);

const fields = (guideline: ServerGuideline): [string, string | null][] => [
    ['Comment', guideline.cpicComment],
    ['Phenotype consultation text', guideline.phenotype.cpicConsultationText],
    ['Implication', guideline.cpicImplication],
    ['Recommendation', guideline.cpicRecommendation],
];

const CpicGuidelineBox = ({ guideline }: { guideline: ServerGuideline }) => (
    <div className="space-y-4 border border-black border-opacity-10 p-4">
        <h2 className="font-bold pb-2">
            CPIC Guideline:{' '}
            <a
                className="underline"
                href={guideline.cpicGuidelineUrl}
                target="_blank"
                rel="noreferrer"
            >
                {guideline.cpicGuidelineName}
            </a>{' '}
            ({guideline.cpicClassification})
        </h2>
        {fields(guideline)
            .filter(([, content]) => content)
            .map(([title, content], index) => (
                <CpicSection key={index} title={title} content={content!} />
            ))}
    </div>
);

export default CpicGuidelineBox;
