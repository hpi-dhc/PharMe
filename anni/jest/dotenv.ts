import { config } from 'dotenv';

const env = config().parsed;
if (env) {
    Object.entries(env).forEach(([key, value]) => {
        process.env[key.replace(/^_TEST_/, '')] = value;
    });
}
