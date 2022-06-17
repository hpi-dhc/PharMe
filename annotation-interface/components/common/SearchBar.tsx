type Props = {
    query: string;
    setQuery: (newQuery: string) => void;
    placeholder?: string;
};

const SearchBar = ({ query, setQuery, placeholder }: Props) => {
    return (
        <input
            className="w-full p-2 mb-6 border border-opacity-10 border-black"
            type="text"
            placeholder={placeholder ?? 'Search'}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
        />
    );
};

export default SearchBar;
