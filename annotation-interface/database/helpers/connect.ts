// analogous to official example
// https://github.com/vercel/next.js/blob/canary/examples/with-mongodb-mongoose/lib/dbConnect.js

import mongoose from 'mongoose';

const MONGODB_URI = `mongodb://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}`;

export default async function dbConnect(): Promise<typeof mongoose> {
    if (global.mongooseConn) {
        return global.mongooseConn;
    }

    if (!global.mongoosePromise) {
        const opts = {
            bufferCommands: false,
        };

        global.mongoosePromise = mongoose.connect(MONGODB_URI, opts);
    }
    global.mongooseConn = await global.mongoosePromise;
    return global.mongooseConn;
}
