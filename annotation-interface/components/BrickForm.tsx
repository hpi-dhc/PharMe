import { UploadIcon } from '@heroicons/react/outline';
import { XIcon, TrashIcon } from '@heroicons/react/solid';
import { useRouter } from 'next/router';
import { useEffect, useRef, useState } from 'react';

import {
    BrickUsage,
    SupportedLanguage,
    supportedLanguages,
} from '../common/constants';
import {
    translationIsValid,
    translationsToArray,
    ITextBrickTranslation,
} from '../database/models/TextBrick';
import SelectionPopover from './SelectionPopover';
const BrickForm = ({ usage }: { usage: BrickUsage | null }) => {
    const router = useRouter();

    // MARK: Errors
    const [message, setMessage] = useState('');

    // MARK: Translations
    const [translations, setTranslations] = useState(
        new Map<SupportedLanguage, string>(),
    );
    const validTranslations = useRef<ITextBrickTranslation[]>([]);
    const [isValid, setIsValid] = useState(true);
    useEffect(() => {
        validTranslations.current = translationsToArray(translations).filter(
            (translation) => translationIsValid(translation),
        );
        setIsValid(validTranslations.current.length > 0);
    }, [translations]);
    const [missingLanguages, setMissingLanguages] = useState<
        SupportedLanguage[]
    >([]);
    useEffect(() => {
        const definedLanguages = new Set(translations.keys());
        setMissingLanguages(
            supportedLanguages.filter(
                (language) => !definedLanguages.has(language),
            ),
        );
    }, [translations]);

    // MARK: CRUD
    const updateTranslation = (
        language: SupportedLanguage,
        text: string,
    ): void => {
        setTranslations((prev) => new Map(prev).set(language, text));
    };
    const deleteTranslation = (language: SupportedLanguage): void => {
        setTranslations((prev) => {
            const n = new Map(prev);
            n.delete(language);
            return n;
        });
    };
    const save = async () => {
        try {
            const res = await fetch('/api/bricks', {
                method: 'POST',
                headers: {
                    Accept: 'application/json',
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    usage,
                    translations: validTranslations.current,
                }),
            });
            if (!res.ok) throw new Error(res.status.toString());
            done();
        } catch (error) {
            setMessage('Failed to add new Brick.');
        }
    };

    const done = () => {
        router.push('/bricks/');
    };

    if (!usage) {
        return <p className="py-4">Please select a usage category above.</p>;
    }

    return (
        <div className="space-y-4 my-4">
            {supportedLanguages
                .filter((language) => translations.has(language))
                .map((language, index) => (
                    <div key={index} className="space-y-1">
                        <div className="flex justify-between">
                            <h2 className="font-bold">{language}</h2>
                            <button
                                className="inline-flex"
                                onClick={() => deleteTranslation(language)}
                            >
                                Delete translation
                                <TrashIcon className="h-5 w-5 ml-2"></TrashIcon>
                            </button>
                        </div>
                        <textarea
                            className="resize-y w-full border border-black border-opacity-10 p-2"
                            value={translations.get(language)}
                            onChange={(e) =>
                                updateTranslation(language, e.target.value)
                            }
                        ></textarea>
                    </div>
                ))}
            {missingLanguages.length > 0 && (
                <div className="flex justify-center">
                    <SelectionPopover
                        label="Add new translation"
                        options={missingLanguages}
                        onSelect={(language) => updateTranslation(language, '')}
                    />
                </div>
            )}
            <div>
                <p>{message}</p>
            </div>
            <div className="flex justify-between">
                <button className="inline-flex" onClick={() => done()}>
                    <XIcon className="h-5 w-5 mr-2"></XIcon>
                    Cancel
                </button>
                <button
                    className={`inline-flex ${
                        isValid || 'opacity-50 line-through'
                    }`}
                    onClick={() => save()}
                    disabled={!isValid}
                >
                    Save Brick
                    <UploadIcon className="h-5 w-5 ml-2"></UploadIcon>
                </button>
            </div>
        </div>
    );
};

export default BrickForm;
