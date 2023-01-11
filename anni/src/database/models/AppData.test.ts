import dbConnect from '../helpers/connect';
import AppData from './AppData';

describe('App data', () => {
    beforeAll(async () => {
        await dbConnect();
        await AppData!.deleteMany({});
    });

    describe('no data', () => {
        it('should get null data', async () => {
            const current = await AppData!.getCurrent();
            expect(current).toBeNull();
        });

        it('should get null version', async () => {
            const version = await AppData!.getVersion();
            expect(version).toBeNull();
        });
    });

    describe('save version 1', () => {
        it('should save a document', async () => {
            const doc = await AppData!.publish({ drugs: [] });
            expect(doc._v).toEqual(1);
        });
    });

    const validateDocAndVersion = (expectedVersion: number) => {
        it('should get the current document', async () => {
            const doc = await AppData!.getCurrent();
            expect(doc).not.toBeNull();
            expect(doc!.drugs).toEqual([]);
        });

        it('should get the current version', async () => {
            const version = await AppData!.getVersion();
            expect(version).not.toBeNull();
            expect(version).toEqual(expectedVersion);
        });

        it('should have exactly one document', async () => {
            const allDocs = await AppData!.find();
            expect(allDocs.length).toEqual(1);
        });
    };

    describe('get version 1', () => {
        validateDocAndVersion(1);
    });

    describe('update version 1', () => {
        it('should update the saved document', async () => {
            const newDoc = await AppData!.publish({ drugs: [] });
            expect(newDoc._v).toEqual(2);
        });
    });

    describe('get version 2', () => {
        validateDocAndVersion(2);
    });
});
