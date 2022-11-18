import { useState } from 'react';

import { warningLevelValues } from '../../common/definitions';
import { IGuideline_Populated } from '../../database/models/Guideline';
import AbstractAnnotation from './AbstractAnnotation';

type Props = {
    guideline: IGuideline_Populated;
};

const WarningLevelAnnotation = ({ guideline }: Props) => {
    const [warningLevel, setWarningLevel] = useState(
        guideline.annotations.warningLevel ?? null,
    );
    return (
        <AbstractAnnotation
            _id={guideline._id!}
            _key="warningLevel"
            stringValue={warningLevel}
            value={warningLevel}
            hasChanges={guideline.annotations.warningLevel !== warningLevel}
            onClear={() => setWarningLevel(null)}
        >
            <div className="border border-opacity-40 border-white py-6 px-2 my-4 flex justify-evenly">
                {warningLevelValues.map((value, index) => (
                    <button
                        key={index}
                        className="py-1 px-3 border border-white border-opacity-50 rounded-xl max-w-max bg-black bg-opacity-0 hover:bg-opacity-50"
                        onClick={() => {
                            setWarningLevel(value);
                        }}
                    >
                        {value}
                    </button>
                ))}
            </div>
        </AbstractAnnotation>
    );
};

export default WarningLevelAnnotation;
