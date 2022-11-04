import { Types } from 'mongoose';

import { ITextBrick } from '../models/TextBrick';

// object ID in database or string ID on client
export type MongooseId = Types.ObjectId | string;
// ID not yet there if we're creating a new object
export type OptionalId = MongooseId | undefined;

export interface IBaseModel<IdT extends OptionalId = undefined> {
    _id?: IdT;
}

// may be
// - not populated -> ID[] of TextBricks
// - populated -> ITextBrick[]
// - resolved -> string
export type BrickAnnotationT = MongooseId[] | ITextBrick<OptionalId>[] | string;
