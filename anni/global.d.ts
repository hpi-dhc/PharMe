/* eslint-disable no-var */

import mongoose from 'mongoose';

declare global {
    var mongoosePromise: Promise<typeof mongoose>;
    var mongooseConn: typeof mongoose;
}
