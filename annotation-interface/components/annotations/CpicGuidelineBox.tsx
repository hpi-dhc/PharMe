import { IGuideline_Any } from '../../database/models/Guideline';

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

type CpicData = IGuideline_Any['cpicData'];

const fields = (guideline: CpicData): [string, string | null][] => [
    ['Comment', guideline.comments ?? null],
    ...Object.entries(guideline.implications).map(
        ([phenotype, implication]) =>
            [`{Implication for ${phenotype}}`, implication] as [string, string],
    ),
    ['Recommendation', guideline.recommendation],
];

const CpicGuidelineBox = ({ guideline }: { guideline: CpicData }) => (
    <div className="space-y-4 border border-black border-opacity-10 p-4">
        <h2 className="font-bold pb-2">
            CPIC Guideline:{' '}
            <a
                className="underline"
                href={guideline.guidelineUrl}
                target="_blank"
                rel="noreferrer"
            >
                {guideline.guidelineName}
            </a>
        </h2>
        {fields(guideline)
            .filter(([, content]) => content)
            .map(([title, content], index) => (
                <CpicSection key={index} title={title} content={content!} />
            ))}
    </div>
);

export default CpicGuidelineBox;
