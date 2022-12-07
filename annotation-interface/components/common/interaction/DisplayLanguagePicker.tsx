import { supportedLanguages } from '../../../common/definitions';
import { useGlobalContext } from '../../../contexts/global';
import SelectionPopover from './SelectionPopover';

const DisplayLanguagePicker = () => {
    const { language, setLanguage } = useGlobalContext();
    return (
        <div>
            <SelectionPopover
                options={[...supportedLanguages]}
                selectedOption={language}
                onSelect={setLanguage}
                expandUpwards
            />
        </div>
    );
};

export default DisplayLanguagePicker;
