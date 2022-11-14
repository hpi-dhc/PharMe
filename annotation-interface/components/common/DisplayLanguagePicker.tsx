import { supportedLanguages } from '../../common/definitions';
import { useLanguageContext } from '../../contexts/language';
import SelectionPopover from './SelectionPopover';

const DisplayLanguagePicker = () => {
    // TODO: expand upwards
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
