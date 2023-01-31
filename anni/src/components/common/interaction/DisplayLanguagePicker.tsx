import SelectionPopover from './SelectionPopover';
import { supportedLanguages } from '../../../common/definitions';
import { useGlobalContext } from '../../../contexts/global';

const DisplayLanguagePicker = () => {
    const { language, setLanguage } = useGlobalContext();
    return (
        <div>
            <SelectionPopover
                options={[...supportedLanguages]}
                selectedOption={language}
                onSelect={setLanguage}
                expandUpwards
                justifyBetween
            />
        </div>
    );
};

export default DisplayLanguagePicker;
