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
    const initialBricks = annotation
        ? resolveBricks(brickResolver, annotation, language)
        : undefined;
    const [selectedBricks, setSelectedBricks] = useState(initialBricks);
    const onClear = () => {
        setSelectedBricks(undefined);
    };

    const query = new URLSearchParams({
        usage: brickCategoryForAnnotationKey[key]!,
    }).toString();
    const { data: response, error } = useSwrFetcher<GetBricksResponse>(
        `/api/bricks?${query}`,
    );

    const allBricks = response?.data.data.bricks
        ? resolveBricks(brickResolver, response.data.data.bricks, language)
        : undefined;

    const stringValue = selectedBricks
        ? selectedBricks
              .map((brick) => brick[1])
              .filter((str) => str)
              .join(' ')
        : null;

    return (
        <AbstractAnnotation
            _id={id}
            _key={key}
            stringValue={stringValue}
            value={selectedBricks?.map(([id]) => id) ?? null}
            hasChanges={selectedBricks !== initialBricks}
            onClear={onClear}
        >
            {error ? (
                <GenericError />
            ) : !allBricks ? (
                <LoadingSpinner />
            ) : (
                <p>editor</p>
            )}
        </AbstractAnnotation>
    );
}

export default BrickAnnotation;
