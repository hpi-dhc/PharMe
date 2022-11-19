import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';
import { mutate } from 'swr';

import { ContextProvider } from '../components/common/structure/Layout';

export const filterStates = ['all', 'missing', 'complete'] as const;
export type FilterState = typeof filterStates[number];

interface IAnnotationContext {
    curationState: FilterState;
    setCurationState: Dispatch<SetStateAction<FilterState>>;
    searchQuery: string;
    setSearchQuery: Dispatch<SetStateAction<string>>;
    mutateAnnotations: () => void;
}

const AnnotationFilterContext = createContext<IAnnotationContext | undefined>(
    undefined,
);

export const AnnotationFilterContextProvider: ContextProvider = ({
    children,
}) => {
    const [curationState, setCurationState] = useState<FilterState>('all');
    const [searchQuery, setSearchQuery] = useState('');
    const mutateAnnotations = () => {
        mutate('api/annotations');
    };
    return (
        <AnnotationFilterContext.Provider
            value={{
                curationState,
                setCurationState,
                searchQuery,
                setSearchQuery,
                mutateAnnotations,
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
