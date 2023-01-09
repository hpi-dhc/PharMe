import { Types } from 'mongoose';

import dbConnect from '../helpers/connect';
import { IBaseDoc } from '../helpers/types';
import { DateRange, IVersionedDoc, versionedModel } from './schema';

interface ITestDoc extends IBaseDoc<Types.ObjectId> {
    value: number;
}

describe('Abstract version control', () => {
    const testModelName = 'TestModel';
    const { schema, makeModel } = versionedModel<
        ITestDoc,
        {
            shouldBeTrue(): () => boolean;
        }
    >(testModelName, {
        value: { type: Number, required: true },
    });
    schema.statics.shouldBeTrue = function (this: typeof TestModel) {
        return this.name === testModelName;
    };
    const TestModel = makeModel();

    const preSaveDate = new Date().getTime();
    let initialDoc: IVersionedDoc<ITestDoc>;
    let saveDate: number;

    beforeAll(async () => {
        await dbConnect();
    });

    describe('Model', () => {
        it('should run static method on model', () => {
            expect(TestModel.shouldBeTrue).toBeTruthy();
        });
    });

    describe('Empty history', () => {
        it('should find no documents in empty history', async () => {
            const docs = await TestModel.findVersionsInRange(
                new Types.ObjectId(),
                [new Date().getTime(), null],
            );
            expect(docs.length).toEqual(0);
        });
    });

    describe('Initialize data', () => {
        it('should save a document', async () => {
            const doc = await TestModel.create({ value: 1 });
            initialDoc = doc;
            saveDate = new Date().getTime();
        });
    });

    describe('First version', () => {
        it(`should find the document's first version`, async () => {
            const version = await initialDoc.findHistoryDoc();
            expect(version._v).toBe(1);

            const version1 = await TestModel.findOneVersion(initialDoc._id!, 1);
            expect(version1).not.toBeNull();
            expect(version1!._id).toEqual(version._id);
        });
    });

    describe('Version dates', () => {
        it('should retrieve a version by date', async () => {
            const doc = await TestModel.findVersionByDate(
                initialDoc._id!,
                saveDate,
            );
            expect(doc).not.toBeNull();
            expect(doc!._v).toEqual(initialDoc._v);
            expect(doc!._ref).toEqual(initialDoc._id!);
        });

        it('should have correct version date range', async () => {
            const range = await initialDoc.dateRange();
            expect(range[0]).toBeLessThanOrEqual(saveDate);
            expect(range[1]).toBeNull();
        });
    });

    describe('Update data', () => {
        it('should modify the data entry creating a new version', async () => {
            const doc = await TestModel.findOneAndUpdate(
                initialDoc._id!,
                {
                    value: 2,
                },
                { new: true },
            );
            expect(doc).not.toBeNull();
            expect(doc!.value).toEqual(2);
            expect(doc!._v).toEqual(2);
            expect(doc!._id).toEqual(initialDoc._id!);
        });
    });

    describe('Version history & date ranges', () => {
        it('should get all document versions', async () => {
            const docs = await TestModel.findVersions(initialDoc._id!);
            expect(docs.length).toEqual(2);
        });

        const expectDocsInRange = async (
            values: Array<number>,
            range: DateRange,
        ) => {
            const docs = await TestModel.findVersionsInRange(
                initialDoc._id!,
                range,
            );
            expect(docs.map((doc) => doc.value)).toEqual(values);
        };

        it('should find only first version in its own range', async () => {
            await expectDocsInRange([1], await initialDoc.dateRange());
        });

        it('should find only second version in its own range', async () => {
            const doc = await TestModel.findById(initialDoc._id!);
            expect(doc).not.toBeNull();
            const range = await doc!.dateRange();
            await expectDocsInRange([2], range);
        });

        it('should find both versions between <date after save of first> and <now>', async () => {
            await expectDocsInRange([1, 2], [saveDate, null]);
        });

        it('should find only first version between <date before save of first> and <date after>', async () => {
            await expectDocsInRange([1], [preSaveDate, saveDate]);
        });

        it('should find only second version between <now> and <now>', async () => {
            await expectDocsInRange([2], [new Date().getTime(), null]);
        });
    });
});
