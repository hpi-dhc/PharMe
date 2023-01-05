import { Types } from 'mongoose';

// object ID in database or string ID on client
export type MongooseId = Types.ObjectId | string;
// ID not yet there if we're creating a new object
export type OptionalId = MongooseId | undefined;

export interface IBaseDoc<IdT extends OptionalId = undefined> {
    _id?: IdT;
}

/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
export function makeIdsStrings(
    obj: any,
    exceptions: Record<string, (obj: any, parent: any) => any> = {},
): any {
    if (obj === undefined) return null;
    if (!(obj instanceof Object)) return obj;
    if (obj instanceof Array) {
        return obj.map((e) => makeIdsStrings(e, exceptions));
    }

    let keys = Object.keys(obj);
    if ('schema' in obj && 'paths' in obj['schema']) {
        keys = Object.keys(obj.schema.paths);
    }
    return keys.reduce((newObj: any, key: string) => {
        if (key in exceptions) {
            newObj[key] = exceptions[key](obj[key], obj);
        } else if (key === '_id') {
            newObj[key] = obj[key].toString();
        } else {
            newObj[key] = makeIdsStrings(obj[key], exceptions);
        }
        return newObj;
    }, new Object());
}
