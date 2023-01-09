import mongoose, { Types } from 'mongoose';

import { IBaseDoc, MongooseId, OptionalId } from '../helpers/types';
import { IVersionedDoc, versionedModel } from '../versioning/schema';
import { IDrug_Resolved } from './Drug';

export interface IAppData<
    DrugT extends MongooseId | IDrug_Resolved,
    IdT extends OptionalId = undefined,
> extends IBaseDoc<IdT> {
    drugs: DrugT[];
}

export type IAppData_DB = IAppData<Types.ObjectId, Types.ObjectId>;
export type IAppData_Patch = Partial<
    IAppData<MongooseId | IDrug_Resolved, undefined>
>;

const { schema, makeModel } = versionedModel<
    IAppData_DB,
    {
        getCurrent: () => Promise<IVersionedDoc<IAppData_DB> | null>;
        getVersion: () => Promise<number | null>;
        publish: (data: IAppData_Patch) => Promise<IVersionedDoc<IAppData_DB>>;
    }
>('AppData', {
    drugs: {
        type: [{ type: Types.ObjectId, ref: 'Drug' }],
        required: true,
    },
});

schema.statics.getCurrent = async function (
    this: ReturnType<typeof makeModel>,
) {
    return this.findOne();
};

schema.statics.getVersion = async function (
    this: ReturnType<typeof makeModel>,
) {
    const current = await this.findOne();
    return current?._v ?? null;
};

schema.statics.publish = async function (
    this: ReturnType<typeof makeModel>,
    data: IAppData_Patch,
) {
    try {
        const doc = await this.findOneAndUpdate(undefined, data);
        return doc;
    } catch {
        return this.create(data);
    }
};

/* istanbul ignore next */
export default !mongoose.models ? undefined : makeModel();
