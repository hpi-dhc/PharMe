const PlaceholderInfo = () => (
    <p>
        <span className="font-bold uppercase tracking-tighter mr-2">Hint </span>
        You can use placeholders like{' '}
        <span className="underline">#drug-name</span> for annotation-specific
        information that will automatically be inserted when using this brick.
        Placeholders always start with a hash (#); try typing one to see which
        placeholders are available!
    </p>
);

export default PlaceholderInfo;
