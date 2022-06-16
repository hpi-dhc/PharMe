import {
    createContext,
    Dispatch,
    SetStateAction,
    useContext,
    useState,
} from 'react';

import { SupportedLanguage } from '../common/constants';
import { ContextProvider } from '../components/common/Layout';

interface ILanguageContext {
    language: SupportedLanguage;
    setLanguage: Dispatch<SetStateAction<SupportedLanguage>>;
}

const LanguageContext = createContext<ILanguageContext | undefined>(undefined);

export const LanguageContextProvider: ContextProvider = ({ children }) => {
    const [language, setLanguage] = useState<SupportedLanguage>('English');
    return (
        <LanguageContext.Provider value={{ language, setLanguage }}>
            {children}
        </LanguageContext.Provider>
    );
};

export const useLanguageContext = (): ILanguageContext => {
    const context = useContext(LanguageContext);
    if (!context) throw Error('Missing provider for language context');
    return context;
};
