import { supportedLanguages } from '../../common/constants';
import { useLanguageContext } from '../../contexts/language';
import SelectionPopover from './SelectionPopover';

const DisplayLanguagePicker = () => {
    const { language, setLanguage } = useLanguageContext();
    return (
        <SelectionPopover
            options={[...supportedLanguages]}
            selectedOption={language}
            onSelect={setLanguage}
        />
    );
};

export default DisplayLanguagePicker;
