module.exports = {
    host: process.env.DB_HOST,
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    seeds: ['src/**/*.seeder.ts'],
    type: 'postgres',
    entities: ['src/**/entities/*.entity{.ts,.js}'],
    synchronize: true,
    logging: true,
};
