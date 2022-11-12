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

export interface IAnnotationModel<IdT extends OptionalId, AT>
    extends IBaseModel<IdT> {
    annotations: AT;
}

/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
function _makeIdsStrings(v: any): any {
    if (v === undefined) return null;
    if (!(v instanceof Object)) return v;
    if (v instanceof Array) {
        return v.map((e) => _makeIdsStrings(e));
    } else {
        return makeIdsStrings(v);
    }
}
export function makeIdsStrings(doc: any): any {
    let keys = Object.keys(doc);
    if ('schema' in doc && 'paths' in doc['schema']) {
        keys = Object.keys(doc.schema.paths);
    }
    return keys.reduce((newObj: any, p: string) => {
        newObj[p] = p === '_id' ? doc[p].toString() : _makeIdsStrings(doc[p]);
        return newObj;
    }, new Object());
}
