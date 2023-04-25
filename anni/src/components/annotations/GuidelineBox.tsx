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
    sources: sources,
}: {
    sources: IGuideline_Any['externalData'];
}) => {
    if (sources.length == 0) return <></>;
    return (
        <div className="space-y-4 border border-black border-opacity-10 p-4">
            {sources.map((source) => (
                <>
                    <h2 className="font-bold pb-2 text-xl">
                        {source.source} Guideline:{' '}
                        <a
                            className="underline"
                            href={source.guidelineUrl}
                            target="_blank"
                            rel="noreferrer"
                        >
                            {source.guidelineName}
                        </a>
                    </h2>
                    <div className="space-y-2">
                        <Section title="Implications" />
                        {Object.entries(source.implications).map(
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
                    <Section
                        title="Recommendation"
                        content={source.recommendation}
                    />
                    {source.comments && (
                        <Section title="Comments" content={source.comments} />
                    )}
                </>
            ))}
        </div>
    );
};

export default GuidelineBox;
