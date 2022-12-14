import { ITextBrick } from '../models/TextBrick';
import { IBaseModel, MongooseId, OptionalId } from './types';

// may be
// - not populated -> ID[] of TextBricks
// - populated -> ITextBrick[]
// - resolved -> string
export type BrickAnnotationT = MongooseId[] | ITextBrick<OptionalId>[] | string;

export interface IAnnotationModel<IdT extends OptionalId, AT>
    extends IBaseModel<IdT> {
    annotations: AT;
    isStaged: boolean;
}

export type CurationState = {
    total: number;
    curated: number;
};
