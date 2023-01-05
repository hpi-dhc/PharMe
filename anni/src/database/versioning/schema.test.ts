import { Types } from 'mongoose';

import dbConnect from '../helpers/connect';
import { IBaseDoc } from '../helpers/types';
import { IVersionedDoc, versionedModel } from './schema';

interface ITestDoc extends IBaseDoc<Types.ObjectId> {
    value: number;
}

describe('Abstract version control', () => {
    const { makeModel } = versionedModel<ITestDoc>('TestModel', {
        value: { type: Number, required: true },
    });
    const TestModel = makeModel();
    let initialDoc: IVersionedDoc<ITestDoc>;
    let saveDate: Date;

    beforeAll(async () => {
        await dbConnect();
    });

    describe('Initialize data', () => {
        it('should save a data entry', async () => {
            const doc = await TestModel.create({ value: 1 });
            initialDoc = doc;
            saveDate = new Date();
        });
    });

    describe('Version dates', () => {
        it('should retrieve version by date', async () => {
            const doc = await TestModel.findVersionByDate(
                initialDoc._id!,
                saveDate,
            );
            expect(doc).not.toBeNull();
            expect(doc!._v).toEqual(1);
            expect(doc!._ref).toEqual(initialDoc._id!);
        });

        it('should have correct version date range', async () => {
            const range = await initialDoc.dateRange();
            expect(range[0].getDate()).toBeLessThanOrEqual(saveDate.getDate());
            expect(range[1]).toBeNull();
        });
    });
});
