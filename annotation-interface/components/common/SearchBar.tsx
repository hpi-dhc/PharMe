import { SearchIcon } from '@heroicons/react/outline';

type Props = {
    query: string;
    setQuery: (newQuery: string) => void;
    placeholder?: string;
    dark?: boolean;
    onEnter?: () => boolean;
};

const SearchBar = ({ query, setQuery, placeholder, dark, onEnter }: Props) => {
    return (
        <div className="relative w-full text-sm">
            <SearchIcon className="pointer-events-none w-4 h-4 absolute top-1/2 transform -translate-y-1/2 left-2 opacity-60" />
            <input
                className={`w-full pl-8 p-2 px-6 rounded-lg border ${
                    dark
                        ? 'border-white border-opacity-20'
                        : 'border-black border-opacity-10'
                } bg-transparent`}
                type="text"
                placeholder={placeholder ?? 'Search'}
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                onKeyDown={(e) => {
                    if (e.key === 'Enter' && onEnter) {
                        onEnter() && setQuery('');
                        e.preventDefault();
                    }
                }}
                autoFocus
            />
        </div>
    );
};

export default SearchBar;
