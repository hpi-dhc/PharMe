import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';

import { brickUsages } from '../common/constants';
import { ContextProvider } from '../components/common/Layout';

export const displayCategories = ['All', ...brickUsages] as const;
export type DisplayCategory = typeof displayCategories[number];
export const displayCategoryForIndex = (index: number): DisplayCategory =>
    displayCategories[index];
export const indexForDisplayCategory = (category: DisplayCategory): number =>
    displayCategories.indexOf(category);

interface IBrickFilterContext {
    categoryIndex: number;
    setCategoryIndex: Dispatch<SetStateAction<number>>;
}

const BrickFilterContext = createContext<IBrickFilterContext | undefined>(
    undefined,
);

export const BrickFilterContextProvider: ContextProvider = ({ children }) => {
    const [categoryIndex, setCategoryIndex] = useState(0);
    return (
        <BrickFilterContext.Provider
            value={{ categoryIndex, setCategoryIndex }}
        >
            {children}
        </BrickFilterContext.Provider>
    );
};

export const useBrickFilterContext = (): IBrickFilterContext => {
    const context = useContext(BrickFilterContext);
    if (!context) throw Error('Missing provider for language context');
    return context;
};
