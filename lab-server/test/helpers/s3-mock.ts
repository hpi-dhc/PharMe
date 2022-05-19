import { Readable } from 'stream';

export interface MockS3File {
    name: string;
    buffer: Buffer;
}

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const MockS3Instance = (mockedFiles: MockS3File[]) => {
    return {
        client: {
            getObject: jest.fn().mockImplementation((_, objectName: string) => {
                const file = mockedFiles.find(
                    (file) => file.name === objectName,
                );
                return Readable.from(file.buffer.toString());
            }),
        },
    };
};
