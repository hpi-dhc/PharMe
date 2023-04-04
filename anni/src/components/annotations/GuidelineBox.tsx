import { IGuideline_Any } from '../../database/models/Guideline';

const Section = ({
    title,
    content,
    indent,
}: {
    title: string;
    content?: string;
    indent?: boolean;
}) => (
    <p className={indent ? 'ml-4' : ''}>
        <span className="font-bold uppercase tracking-tighter mr-2">
            {title}
        </span>
        {content}
    </p>
);

const GuidelineBox = ({
    guideline,
}: {
    guideline: IGuideline_Any['cpicData'];
}) => (
    <div className="space-y-4 border border-black border-opacity-10 p-4">
        <h2 className="font-bold pb-2 text-xl">
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
        <div className="space-y-2">
            <Section title="Implications" />
            {Object.entries(guideline.implications).map(
                ([phenotype, implication], index) => (
                    <Section
                        key={index}
                        title={phenotype}
                        content={implication}
                        indent
                    />
                ),
            )}
        </div>
        <Section title="Recommendation" content={guideline.recommendation} />
        {guideline.comments && (
            <Section title="Comments" content={guideline.comments} />
        )}
    </div>
);

export default GuidelineBox;
