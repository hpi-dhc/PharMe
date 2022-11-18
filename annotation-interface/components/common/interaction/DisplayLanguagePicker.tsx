import { supportedLanguages } from '../../../common/definitions';
import { useLanguageContext } from '../../../contexts/language';
import SelectionPopover from './SelectionPopover';

const DisplayLanguagePicker = () => {
    const { language, setLanguage } = useLanguageContext();
    return (
        <SelectionPopover
            options={[...supportedLanguages]}
            selectedOption={language}
            onSelect={setLanguage}
            expandUpwards
        />
    );
};

export default DisplayLanguagePicker;
