import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';

import { ContextProvider } from '../components/common/Layout';

export const filterStates = ['all', 'missing', 'fully curated'] as const;
export type FilterState = typeof filterStates[number];

interface IAnnotationFilterContext {
    curationState: FilterState;
    setCurationState: Dispatch<SetStateAction<FilterState>>;
    searchQuery: string;
    setSearchQuery: Dispatch<SetStateAction<string>>;
}

const AnnotationFilterContext = createContext<
    IAnnotationFilterContext | undefined
>(undefined);

export const AnnotationFilterContextProvider: ContextProvider = ({
    children,
}) => {
    const [curationState, setCurationState] = useState<FilterState>('all');
    const [searchQuery, setSearchQuery] = useState('');
    return (
        <AnnotationFilterContext.Provider
            value={{
                curationState,
                setCurationState,
                searchQuery,
                setSearchQuery,
            }}
        >
            {children}
        </AnnotationFilterContext.Provider>
    );
};

export const useAnnotationFilterContext = (): IAnnotationFilterContext => {
    const context = useContext(AnnotationFilterContext);
    if (!context) throw Error('Missing provider for annotation filter context');
    return context;
};
