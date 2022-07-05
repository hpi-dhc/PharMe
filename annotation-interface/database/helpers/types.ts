import { Types } from 'mongoose';

export type MongooseId = Types.ObjectId | string;
export type OptionalId = MongooseId | undefined;

export interface IBaseModel<IdT extends OptionalId = undefined> {
    _id?: IdT;
}
