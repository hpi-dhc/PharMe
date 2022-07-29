import * as Joi from 'joi';

export const envSchema = Joi.object({
    // NodeJS
    NODE_ENV: Joi.string()
        .valid('development', 'production', 'test')
        .default('development'),
    PORT: Joi.number().port().default(3000),
    // Database
    DB_HOST: Joi.string().default('localhost'),
    DB_PORT: Joi.number().port().default(5432),
    DB_USER: Joi.string().default('admin'),
    DB_PASS: Joi.string().default('admin'),
    DB_NAME: Joi.string().default('annotation_db'),
    // Medications
    DRUGBANK_ZIP: Joi.string().default('data/example-database.zip'),
    DRUGBANK_XML: Joi.string().default('example-database.xml'),
    // Google Sheets
    GOOGLESHEET_ID: Joi.string().required(),
    GOOGLESHEET_APIKEY: Joi.string().required(),
    GOOGLESHEET_RANGE_MEDICATIONS: Joi.string().default('HPI List v1!D4:D'),
    GOOGLESHEET_RANGE_DRUGCLASSES: Joi.string().default('HPI List v1!A4:A'),
    GOOGLESHEET_RANGE_INDICATIONS: Joi.string().default('HPI List v1!M4:M'),
    GOOGLESHEET_RANGE_GENES: Joi.string().default('HPI List v1!E4:E'),
    GOOGLESHEET_RANGE_PHENOTYPES: Joi.string().default('HPI List v1!N3:V3'),
    GOOGLESHEET_RANGE_IMPLICATIONS: Joi.string().default('HPI List v1!N4:V'),
    GOOGLESHEET_RANGE_RECOMMENDATIONS:
        Joi.string().default('HPI List v1!W4:AE'),
});

export const testEnvSchema = envSchema.keys({
    EMPTY_GOOGLESHEET_ID: Joi.string().required(),
});
