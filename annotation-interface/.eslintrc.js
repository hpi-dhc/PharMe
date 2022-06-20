module.exports = {
  env: {
    node: true,
    jest: true,
  },
  extends: [
    'next/core-web-vitals',
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint', 'nestjs', 'prettier', 'import'],
  ignorePatterns: ['.eslintrc.js'],
  root: true,
  rules: {
    'prettier/prettier': 2,
    'no-tabs': ['error'],
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single', { 'allowTemplateLiterals': true }],
    semi: ['error', 'always'],
    'import/first': 'error',
    'import/named': 'error',
    'import/namespace': 'error',
    'import/default': 'error',
    'import/export': 'error',
    'import/order': [
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'index',
          ['sibling', 'parent'],
        ],
        'newlines-between': 'always',
        alphabetize: {
          order: 'asc',
        },
      },
    ],
    'space-before-function-paren': [
      'error',
      {
        anonymous: 'always',
        named: 'never', // Only remove spaces for something like function abc() {}
        asyncArrow: 'always',
      },
    ],
    'no-console': 'warn',
    'no-warning-comments': 'warn',

    'comma-dangle': ['error', 'always-multiline'],

    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-module-boundary-types': 'error',

    // we need this due to our injections in services and controllers
    'no-useless-constructor': 'off',
  },

  'overrides': [
      // to allow for NextJS inferred typing like this
      // https://nextjs.org/docs/api-reference/data-fetching/get-server-side-props
    {
      'files': ['*.tsx'],
      'rules': {
        '@typescript-eslint/explicit-module-boundary-types': ['off']
      }
    }
  ],

  settings: {
    // This uses the eslint-import-resolver-typescript npm module to properly
    // resolve the imports. Without it, the linter thinks 'utils/error' is an
    // external package, whereas it is just an absolute import.
    'import/resolver': 'typescript',
  },
};
