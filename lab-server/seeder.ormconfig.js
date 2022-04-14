const path = require('path'); // eslint-disable-line

module.exports = {
    host: process.env.LAB_SERVER_DB_HOST,
    username: process.env.LAB_SERVER_DB_USER,
    password: process.env.LAB_SERVER_DB_PASS,
    port: process.env.LAB_SERVER_DB_PORT,
    database: process.env.LAB_SERVER_DB_NAME,
    seeds: ['src/**/*.seeder.ts'],
    type: 'postgres',
    entities: ['src/**/entities/*.entity{.ts,.js}'],
    synchronize: true,
    logging: true,
};
