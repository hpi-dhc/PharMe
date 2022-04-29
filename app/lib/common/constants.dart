final serverUrl = Uri.http('10.0.2.2', '');
final annotationServerUrl = serverUrl.replace(port: 3000, path: 'api/v1');
final labServerUrl = serverUrl.replace(port: 8081, path: 'api/v1');
final keycloakUrl = serverUrl.replace(port: 28080);
final cpicMaxCacheTime = Duration(days: 90);
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,lookupkey';
