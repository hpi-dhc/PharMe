/*
 * For a detailed explanation regarding each configuration property and type check, visit:
 * https://jestjs.io/docs/configuration
 */
const config = {
    rootDir: '..',

    collectCoverage: true,
    coverageDirectory: 'coverage',
    coveragePathIgnorePatterns: [
        '/coverage/',
        '/node_modules/',
        '/.next/',
        '__tests__',
    ],

    testMatch: [
        '<rootDir>/src/**/__tests__/**/*.[jt]s?(x)',
        '<rootDir>/src/**/?(*.)+(spec|test).[tj]s?(x)',
    ],

    transform: {
        '^.+\\.(t|j)s$': 'ts-jest',
    },

    setupFiles: ['<rootDir>/jest/dotenv.ts'],
};

export default config;
