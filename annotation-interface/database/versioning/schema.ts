import mongoose, {
    Model,
    SchemaDefinition,
    SchemaDefinitionType,
    SchemaOptions,
    Types,
} from 'mongoose';

type IVDoc<DocT> = DocT & {
    _ref?: Types.ObjectId;
    _v?: number;
};

export function versionedModel<DocT>(
    modelName: string,
    definition: SchemaDefinition<SchemaDefinitionType<DocT>>,
    options?: SchemaOptions,
): { schema: mongoose.Schema<DocT, Model<DocT>>; model: Model<DocT> } {
    type IVD = IVDoc<DocT>;
    const schema = new mongoose.Schema<IVD, Model<IVD>>(
        {
            ...definition,
            _v: { type: Number, required: true },
            _ref: { type: Types.ObjectId, ref: modelName, required: true },
        },
        options,
    );
    schema.index({ _ref: 'hashed', _v: 1 }, { unique: true });
    const model = mongoose.model<IVD, Model<IVD>>(modelName, schema);

    schema.pre('save', async function (this: IVD) {
        console.log('save');
    });
    schema.pre(/updateOne|findOneAndUpdate/, async function (this: IVD) {
        console.log('versioning');
    });

    return { schema, model };
}
