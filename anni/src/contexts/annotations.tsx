import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';

import { ContextProvider } from '../components/common/structure/Layout';

export const filterStates = ['all', 'missing', 'complete'] as const;
export type FilterState = typeof filterStates[number];

interface IAnnotationContext {
    curationFilter: FilterState;
    setCurationState: Dispatch<SetStateAction<FilterState>>;
    searchQuery: string;
    setSearchQuery: Dispatch<SetStateAction<string>>;
}

const AnnotationFilterContext = createContext<IAnnotationContext | undefined>(
    undefined,
);

export const AnnotationFilterContextProvider: ContextProvider = ({
    children,
}) => {
    const [curationFilter, setCurationState] = useState<FilterState>('all');
    const [searchQuery, setSearchQuery] = useState('');
    return (
        <AnnotationFilterContext.Provider
            value={{
                curationFilter,
                setCurationState,
                searchQuery,
                setSearchQuery,
            }}
        >
            {children}
        </AnnotationFilterContext.Provider>
    );
};

export const useAnnotationContext = (): IAnnotationContext => {
    const context = useContext(AnnotationFilterContext);
    if (!context) throw Error('Missing provider for annotation filter context');
    return context;
};
