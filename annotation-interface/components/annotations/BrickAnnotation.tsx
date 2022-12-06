import Link from 'next/link';
import { useState } from 'react';

import {
    AnnotationKey,
    brickCategoryForAnnotationKey,
} from '../../common/definitions';
import { useSwrFetcher } from '../../common/react-helpers';
import { useLanguageContext } from '../../contexts/language';
import {
    BrickResolver,
    resolveBricks,
} from '../../database/helpers/resolve-bricks';
import { ITextBrick_Str } from '../../database/models/TextBrick';
import { GetBricksResponse } from '../../pages/api/bricks';
import GenericError from '../common/indicators/GenericError';
import LoadingSpinner from '../common/indicators/LoadingSpinner';
import AbstractAnnotation from './AbstractAnnotation';
import BrickAnnotationEditor from './BrickAnnotationEditor';

interface Props {
    _id: string;
    _key: AnnotationKey;
    annotation: Array<ITextBrick_Str> | undefined;
    brickResolver: BrickResolver;
    isEditable: boolean;
}

function BrickAnnotation({
    _id: id,
    _key: key,
    annotation,
    brickResolver,
    isEditable,
}: Props) {
    const { language } = useLanguageContext();
    const initialBrickIds = annotation
        ? new Set(annotation.map((brick) => brick._id!))
        : undefined;
    const [usedBrickIds, setUsedBrickIds] = useState(initialBrickIds);
    const onClear = () => {
        setUsedBrickIds(undefined);
    };

    const usageParams = new URLSearchParams({
        usage: brickCategoryForAnnotationKey[key]!,
    }).toString();
    const { data: response, error } = useSwrFetcher<GetBricksResponse>(
        `/api/bricks?${usageParams}`,
    );
    const allBricks = response?.data.data.bricks
        ? new Map(
              resolveBricks(
                  brickResolver,
                  response.data.data.bricks,
                  language,
              ).map(([id, text]) => [id, text ?? '<Missing translation!>']),
          )
        : undefined;

    const stringValue = usedBrickIds
        ? Array.from(usedBrickIds)
              .map((id) => allBricks?.get(id))
              .join(' ')
        : null;

    return (
        <AbstractAnnotation
            _id={id}
            _key={key}
            stringValue={stringValue}
            value={usedBrickIds ? Array.from(usedBrickIds) : null}
            hasChanges={usedBrickIds !== initialBrickIds}
            onClear={onClear}
            isEditable={isEditable}
        >
            {error ? (
                <GenericError />
            ) : !allBricks ? (
                <LoadingSpinner />
            ) : !allBricks.size ? (
                <div className="mt-4 space-y-4 text-center">
                    <p>
                        Looks like there are no Bricks defined for this type of
                        Annotation yet!
                    </p>
                    <p>
                        <Link href={`/bricks/new?${usageParams}`}>
                            <a className="underline">Create a new Brick now</a>
                        </Link>
                    </p>
                </div>
            ) : (
                <BrickAnnotationEditor
                    allBricks={allBricks}
                    usedIds={usedBrickIds}
                    setUsedIds={setUsedBrickIds}
                />
            )}
        </AbstractAnnotation>
    );
}

export default BrickAnnotation;
