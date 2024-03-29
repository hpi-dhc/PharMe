import mongoose, {
    ApplyBasicQueryCasting,
    Model,
    Query,
    QuerySelector,
    SchemaDefinition,
    SchemaDefinitionType,
    Types,
} from 'mongoose';

import { IBaseDoc, MongooseId } from '../helpers/types';

export type DateRange = [number, number | null];

export type IVersionedDoc<DocT extends IBaseDoc<Types.ObjectId>> = DocT & {
    _v: number;
    _vDate: number;
    findHistoryDoc: () => Promise<IVersionHistoryDoc<DocT>>;
    dateRange: () => Promise<DateRange>;
};

export type IVersionHistoryDoc<DocT extends IBaseDoc<Types.ObjectId>> =
    IVersionedDoc<DocT> & {
        _ref: Types.ObjectId;
    };

export type VersionedModel<DocT, HDocT> = Model<DocT> & {
    findVersions(id: MongooseId): Promise<Array<HDocT>>;
    findOneVersion(id: MongooseId, version: number): Promise<HDocT | null>;
    findVersionByDate(id: MongooseId, date: number): Promise<HDocT | null>;
    findVersionsInRange(
        id: MongooseId,
        dateRange: DateRange,
    ): Promise<Array<HDocT>>;
};

/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
export function versionedModel<
    DocT extends IBaseDoc<Types.ObjectId>,
    Statics extends object = Record<string, never>,
>(modelName: string, definition: SchemaDefinition<SchemaDefinitionType<DocT>>) {
    // type definitions ---------------------------------------------------------
    type VD = IVersionedDoc<DocT>;
    type VHD = IVersionHistoryDoc<DocT>;
    type VM = VersionedModel<VD, VHD> & Statics;
    type VHM = Model<VHD> & {
        saveVersion(document: VD): Promise<void>;
    };

    // versioned model ----------------------------------------------------------
    const schemaDefinition = {
        ...definition,
        _v: { type: Number, required: true },
        _vDate: { type: Number, required: true },
    };
    const schema = new mongoose.Schema<VD, VM>(schemaDefinition, {
        methods: {
            findHistoryDoc: async function (this: VD) {
                return historyModel.findOne({
                    _ref: this._id,
                    _v: this._v,
                });
            },

            dateRange: async function (this) {
                const successor = await historyModel.findOne({
                    _ref: this._id,
                    _v: this._v + 1,
                });
                return [this._vDate, successor?._vDate ?? null];
            },
        },
        statics: {
            findVersions: async function (id: MongooseId): Promise<Array<VHD>> {
                return historyModel.find({ _ref: id });
            },

            findOneVersion: async function (
                id: MongooseId,
                v: number,
            ): Promise<VHD | null> {
                return historyModel.findOne({ _ref: id, _v: v });
            },

            findVersionByDate: async function (
                id: MongooseId,
                date: number,
            ): Promise<VHD | null> {
                return historyModel
                    .findOne({
                        _ref: id,
                        _vDate: { $lte: date },
                    })
                    .sort({ _vDate: 'desc' });
            },

            findVersionsInRange: async function (
                id: MongooseId,
                dateRange: DateRange,
            ): Promise<Array<VHD>> {
                // scenarios:
                //   - range      |--------------|
                //     versions |---a---|-b-|---c---|
                //   - range      |--------------|
                //     versions |---d---|
                // find b & c
                const filter: QuerySelector<
                    ApplyBasicQueryCasting<VHD['_vDate']>
                > = {
                    $gte: dateRange[0],
                };
                if (dateRange[1]) filter['$lt'] = dateRange[1];
                const versions = await historyModel
                    .find({ _ref: id, _vDate: filter })
                    .sort('_vDate');

                if (versions.length === 0) {
                    // find d
                    const only = await historyModel
                        .findOne({ _ref: id })
                        .sort('-_v');
                    return only ? [only] : [];
                } else if (
                    // find a
                    versions[0]._vDate > dateRange[0] &&
                    versions[0]._v > 1
                ) {
                    const oldest = await historyModel.findOne({
                        _ref: id,
                        _v: versions[0]._v - 1,
                    });
                    if (oldest) {
                        versions.unshift(oldest);
                    }
                }
                return versions;
            },
        },
    });
    // versioning middleware
    // save first version & init version number
    schema.pre('validate', async function (this: VD) {
        this._v = 1;
        this._vDate = new Date().getTime();
        await historyModel.saveVersion(this);
    });
    // increment version number on change
    schema.pre(
        /updateOne|findOneAndUpdate|findByIdAndUpdate/,
        async function (this: Query<void, VD>) {
            const doc = await this.model.findOne(this.getQuery());
            this.set('_v', doc._v + 1);
            this.set('_vDate', new Date().getTime());
        },
    );
    // save change to history
    schema.post(
        /updateOne|findOneAndUpdate|findByIdAndUpdate/,
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
    const historySchema = new mongoose.Schema<VHD, VHM>(
        {
            ...schemaDefinition,
            _ref: { type: Types.ObjectId, ref: modelName, required: true },
        },
        {
            statics: {
                saveVersion: async function (document: VD) {
                    const historyDoc: VHD = {
                        ...JSON.parse(JSON.stringify(document)),
                        _ref: document._id!,
                        _id: undefined,
                    };
                    await historyModel.create(historyDoc);
                },
            },
        },
    );
    historySchema.index({ _ref: 'hashed', _v: 1 }, { unique: true });
    historySchema.index({ _ref: 'hashed', _vDate: 1 });
    historySchema.index({ _ref: 'hashed' });
    const hModelName = `${modelName}_History`;
    const historyModel =
        (mongoose.models[hModelName] as VHM) ||
        mongoose.model<VHD, VHM>(hModelName, historySchema);

    return { schema, makeModel };
}
