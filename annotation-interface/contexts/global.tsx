import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';

import { SupportedLanguage } from '../common/definitions';
import { ContextProvider } from '../components/common/structure/Layout';

interface IGlobalContext {
    language: SupportedLanguage;
    setLanguage: Dispatch<SetStateAction<SupportedLanguage>>;
    reviewMode: boolean;
    setReviewMode: Dispatch<SetStateAction<boolean>>;
}

const GlobalContext = createContext<IGlobalContext | undefined>(undefined);

export const GlobalContextProvider: ContextProvider = ({ children }) => {
    const [language, setLanguage] = useState<SupportedLanguage>('English');
    const [reviewMode, setReviewMode] = useState(false);
    return (
        <GlobalContext.Provider
            value={{ language, setLanguage, reviewMode, setReviewMode }}
        >
            {children}
        </GlobalContext.Provider>
    );
};

export const useGlobalContext = (): IGlobalContext => {
    const context = useContext(GlobalContext);
    if (!context) throw Error('Missing provider for language context');
    return context;
};
