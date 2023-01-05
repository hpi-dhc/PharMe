import { Types } from 'mongoose';

import dbConnect from '../helpers/connect';
import { IBaseDoc } from '../helpers/types';
import { DateRange, IVersionedDoc, versionedModel } from './schema';

interface ITestDoc extends IBaseDoc<Types.ObjectId> {
    value: number;
}

describe('Abstract version control', () => {
    const { makeModel } = versionedModel<ITestDoc>('TestModel', {
        value: { type: Number, required: true },
    });
    const TestModel = makeModel();

    const preSaveDate = new Date();
    let initialDoc: IVersionedDoc<ITestDoc>;
    let saveDate: Date;

    beforeAll(async () => {
        await dbConnect();
    });

    describe('Initialize data', () => {
        it('should save a document', async () => {
            const doc = await TestModel.create({ value: 1 });
            initialDoc = doc;
            saveDate = new Date();
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
            expect(range[0].getDate()).toBeLessThanOrEqual(saveDate.getDate());
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

    describe('Version history', () => {
        it('should get all document versions', async () => {
            const docs = await TestModel.findVersions(initialDoc._id!);
            expect(docs.length).toEqual(2);
        });

        it('should find documents in date ranges', async () => {
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

            const doc = await TestModel.findById(initialDoc._id!);
            expect(doc).not.toBeNull();
            const range = await doc!.dateRange();

            await expectDocsInRange([2], range);
            await expectDocsInRange([1, 2], [saveDate, null]);
            await expectDocsInRange([1], [preSaveDate, saveDate]);
            await expectDocsInRange([1], await initialDoc.dateRange());
            await expectDocsInRange([2], [new Date(), null]);
        });
    });
});
