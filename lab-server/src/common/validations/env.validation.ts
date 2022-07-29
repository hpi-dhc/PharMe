import * as Joi from 'joi';

export const envSchema = Joi.object({
    // NodeJS
    NODE_ENV: Joi.string()
        .valid('development', 'production', 'test')
        .default('development'),
    PORT: Joi.number().port().default(3001),
    // Database
    DB_HOST: Joi.string().default('localhost'),
    DB_PORT: Joi.number().port().default(6543),
    DB_USER: Joi.string().default('admin'),
    DB_PASS: Joi.string().default('admin'),
    DB_NAME: Joi.string().default('lab_server_db'),
    // Keycloak Connect Module
    KEYCLOAK_AUTH_SERVER_URL: Joi.string()
        .uri()
        .default('http://127.0.0.1:28080/auth'),
    KEYCLOAK_REALM: Joi.string().default('pharme'),
    KEYCLOAK_CLIENT_ID: Joi.string().default('pharme-lab-server'),
    KEYCLOAK_SECRET: Joi.string().required(),
    // Minio
    MINIO_PORT: Joi.number().port().default(9000),
    MINIO_ENDPOINT: Joi.string().default('127.0.0.1'),
    MINIO_ROOT_USER: Joi.string().default('minio_admin'),
    MINIO_ROOT_PASSWORD: Joi.string().default('minio_admin'),
});
