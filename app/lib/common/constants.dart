Uri anniUrl([String slug = '']) => Uri.http('localhost:3001', 'api/v1/$slug');
Uri labServerUrl([String slug = '']) =>
    Uri.https('lab-server-pharme.dhc-lab.hpi.de', 'api/v1/$slug');
Uri keycloakUrl([String slug = '']) =>
    Uri.https('keycloak-pharme.dhc-lab.hpi.de', slug);

final cpicMaxCacheTime = Duration(days: 90);
const maxCachedDrugs = 10;
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult';
