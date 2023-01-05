import dbConnect from './connect';

test('Database connection', async () => {
    await dbConnect();
    // second call to cover case where connection has already been established
    await dbConnect();
});
