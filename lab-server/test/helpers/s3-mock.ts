import { Readable } from 'stream';

import { allelesFile } from './contstants';

export const MockS3Instance = {
    client: {
        getObject: jest.fn().mockImplementation(() => {
            const buffer = Buffer.from(allelesFile, 'base64');
            return Readable.from(buffer.toString());
        }),
    },
};
