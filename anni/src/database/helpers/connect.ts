import mongoose from 'mongoose';

export default async function dbConnect(): Promise<typeof mongoose> {
    if (global.mongooseConn) {
        return global.mongooseConn;
    }

    if (!global.mongoosePromise) {
        const uri = `mongodb://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}`;
        global.mongoosePromise = mongoose.connect(uri, {
            bufferCommands: false,
        });
    }
    global.mongooseConn = await global.mongoosePromise;
    return global.mongooseConn;
}
