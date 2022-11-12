import {
    AnnotationKey,
    brickCategoryForAnnotationKey,
} from '../../common/definitions';
import { ITextBrick_Str } from '../../database/models/TextBrick';

interface Props {
    _id: string | undefined;
    annotation: Array<ITextBrick_Str> | undefined;
    key: AnnotationKey;
}

function BrickAnnotation({ _id, annotation, key }: Props) {
    console.log(brickCategoryForAnnotationKey[key]);
    console.log(annotation);
    return <div>BrickAnnotation for {_id}</div>;
}

export default BrickAnnotation;
