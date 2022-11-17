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
import GenericError from '../common/GenericError';
import LoadingSpinner from '../common/LoadingSpinner';
import AbstractAnnotation from './AbstractAnnotation';
import BrickAnnotationEditor from './BrickAnnotationEditor';

interface Props {
    _id: string;
    _key: AnnotationKey;
    annotation: Array<ITextBrick_Str> | undefined;
    brickResolver: BrickResolver;
}

function BrickAnnotation({
    _id: id,
    _key: key,
    annotation,
    brickResolver,
}: Props) {
    const { language } = useLanguageContext();
    const initialBrickIds = annotation
        ? new Set(annotation.map((brick) => brick._id!))
        : undefined;
    const [usedBrickIds, setUsedBrickIds] = useState(initialBrickIds);
    const onClear = () => {
        setUsedBrickIds(undefined);
    };

    const { data: response, error } = useSwrFetcher<GetBricksResponse>(
        `/api/bricks?${new URLSearchParams({
            usage: brickCategoryForAnnotationKey[key]!,
        })}`,
    );
    const allBricks = response?.data.data.bricks
        ? new Map(
              resolveBricks(brickResolver, response.data.data.bricks, language),
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
        >
            {error ? (
                <GenericError />
            ) : !allBricks ? (
                <LoadingSpinner />
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
