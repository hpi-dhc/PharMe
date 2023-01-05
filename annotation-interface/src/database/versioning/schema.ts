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

type DateRange = [Date, Date | null];

type IVersionedDoc<DocT extends IBaseDoc<Types.ObjectId>> = DocT & {
    _v: number;
    _vDate: Date;
    findHistoryDoc: () => Promise<IVersionHistoryDoc<DocT>>;
    dateRange: () => Promise<DateRange>;
};

type IVersionHistoryDoc<DocT extends IBaseDoc<Types.ObjectId>> =
    IVersionedDoc<DocT> & {
        _ref: Types.ObjectId;
    };

type VersionedModel<DocT, HDocT> = Model<DocT> & {
    findVersions(id: MongooseId): Promise<Array<HDocT>>;
    findOneVersion(id: MongooseId, version: number): Promise<HDocT | null>;
    findVersionByDate(id: MongooseId, date: Date): Promise<HDocT | null>;
    findVersionsInRange(
        id: MongooseId,
        dateRange: DateRange,
    ): Promise<Array<HDocT>>;
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
        _vDate: { type: Date, required: true },
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
                return [this._vDate, successor?._vDate];
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
                date: Date,
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
                const filter: QuerySelector<
                    ApplyBasicQueryCasting<VHD['_vDate']>
                > = {
                    $gte: dateRange[0],
                };
                if (dateRange[1]) filter['$lte'] = dateRange[1];
                return historyModel.find({ _ref: id, _vDate: filter });
            },
        },
    });
    // versioning middleware
    // save first version & init version number
    schema.pre('validate', async function (this: VD) {
        this._v = 1;
        this._vDate = new Date();
        await historyModel.saveVersion(this);
    });
    // increment version number on change
    schema.pre(
        /updateOne|findOneAndUpdate/,
        async function (this: Query<void, VD>) {
            const doc = await this.model.findOne(this.getQuery());
            this.set('_v', doc._v + 1);
            this.set('_vDate', new Date());
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
