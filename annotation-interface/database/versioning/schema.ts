import mongoose, {
    Model,
    Query,
    SchemaDefinition,
    SchemaDefinitionType,
    Types,
} from 'mongoose';

import { IBaseDoc, MongooseId } from '../helpers/types';

type IVersionedDoc<DocT extends IBaseDoc<Types.ObjectId>> = DocT & {
    _v?: number;
    findHistoryDoc?: () => Promise<IVersionHistoryDoc<DocT>>;
};

type IVersionHistoryDoc<DocT extends IBaseDoc<Types.ObjectId>> =
    IVersionedDoc<DocT> & {
        _ref?: Types.ObjectId;
    };

type VersionedModel<DocT, HDocT> = Model<DocT> & {
    findVersions(id: MongooseId): Promise<Array<HDocT>>;
};

export function versionedModel<DocT extends IBaseDoc<Types.ObjectId>>(
    modelName: string,
    definition: SchemaDefinition<SchemaDefinitionType<DocT>>,
) {
    // type definitions ---------------------------------------------------------
    type VD = IVersionedDoc<DocT>;
    type VHD = IVersionHistoryDoc<DocT>;
    type VM = VersionedModel<VD, VHD>;
    type VHM = Model<VHD> & {
        saveVersion(document: VD): Promise<void>;
    };

    // versioned model ----------------------------------------------------------
    const schemaDefinition = {
        ...definition,
        _v: { type: Number, required: true },
    };
    const schema = new mongoose.Schema<VD, VM>(schemaDefinition);
    schema.static('findVersions', async function (id: MongooseId) {
        return historyModel.find({ _ref: id });
    });
    schema.methods.findHistoryDoc = async function (this: VD) {
        return historyModel.findOne({ _ref: this._id, _v: this._v });
    };
    // versioning middleware
    // save first version & init version number
    schema.pre('validate', async function (this: VD) {
        this._v = 1;
        await historyModel.saveVersion(this);
    });
    // increment version number on change
    schema.pre(
        /updateOne|findOneAndUpdate/,
        async function (this: Query<void, VD>) {
            const doc = await this.model.findOne(this.getQuery());
            this.set('_v', doc._v + 1);
        },
    );
    // save change to history
    schema.post(
        /updateOne|findOneAndUpdate/,
        async function (this: Query<void, VD>) {
            const doc = await this.model.findOne(this.getQuery());
            await historyModel.saveVersion(doc);
        },
    );
    // once model is compiled, no more middleware, methods, etc can be added
    const makeModel = () =>
        (mongoose.models[modelName] as VM) ||
        mongoose.model<VD, VM>(modelName, schema);

    // version history model ----------------------------------------------------
    const historySchema = new mongoose.Schema<VHD, VHM>({
        ...schemaDefinition,
        _ref: { type: Types.ObjectId, ref: modelName, required: true },
    });
    historySchema.index({ _ref: 'hashed', _v: 1 }, { unique: true });
    historySchema.static('saveVersion', async function (document: VD) {
        const historyDoc: VHD = {
            ...JSON.parse(JSON.stringify(document)),
            _ref: document._id!,
            _id: undefined,
        };
        await historyModel.create(historyDoc);
    });
    const hModelName = `${modelName}_History`;
    const historyModel =
        (mongoose.models[hModelName] as VHM) ||
        mongoose.model<VHD, VHM>(hModelName, historySchema);

    return { schema, makeModel };
}
