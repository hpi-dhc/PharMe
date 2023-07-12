import * as Joi from 'joi';

export const envSchema = Joi.object({
    // NodeJS
    NODE_ENV: Joi.string()
        .valid('development', 'production', 'test')
        .default('development'),
    // from .env
    PORT: Joi.number().port().required(),
    DB_HOST: Joi.string().required(),
    DB_PORT: Joi.number().port().required(),
    DB_USER: Joi.string().required(),
    DB_PASS: Joi.string().required(),
    DB_NAME: Joi.string().required(),
    KEYCLOAK_AUTH_SERVER_URL: Joi.string().uri().required(),
    KEYCLOAK_REALM: Joi.string().required(),
    KEYCLOAK_CLIENT_ID: Joi.string().required(),
    KEYCLOAK_SECRET: Joi.string().required(),
    MINIO_PORT: Joi.number().port().required(),
    MINIO_ENDPOINT: Joi.string().required(),
    MINIO_ROOT_USER: Joi.string().required(),
    MINIO_ROOT_PASSWORD: Joi.string().required(),
});
