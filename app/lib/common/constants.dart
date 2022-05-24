final labServerUrl = Uri.https('lab-server-pharme.dhc-lab.hpi.de', 'api/v1');
final annotationServerUrl =
    Uri.https('annotation-server-pharme.dhc-lab.hpi.de', 'api/v1');
final keycloakUrl = Uri.https('keycloak-pharme.dhc-lab.hpi.de', '');
final cpicMaxCacheTime = Duration(days: 90);
final cpicLookupUrl = Uri.https('api.cpicpgx.org', 'v1/diplotype',
    {'select': 'genesymbol,diplotype,lookupkey'});
