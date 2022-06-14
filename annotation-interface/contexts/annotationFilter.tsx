import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';

import { ContextProvider } from '../components/common/Layout';

export const filterStates = ['all', 'missing', 'curated'] as const;
export type FilterState = typeof filterStates[number];

interface IAnnotationFilterContext {
    curationState: FilterState;
    setCurationState: Dispatch<SetStateAction<FilterState>>;
    categoryIndex: number;
    setCategoryIndex: Dispatch<SetStateAction<number>>;
}

const AnnotationFilterContext = createContext<
    IAnnotationFilterContext | undefined
>(undefined);

export const AnnotationFilterContextProvider: ContextProvider = ({
    children,
}) => {
    const [curationState, setCurationState] = useState<FilterState>('all');
    const [categoryIndex, setCategoryIndex] = useState(0);
    return (
        <AnnotationFilterContext.Provider
            value={{
                curationState,
                setCurationState,
                categoryIndex,
                setCategoryIndex,
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
