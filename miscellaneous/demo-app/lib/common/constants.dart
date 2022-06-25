final labServerIp = Uri.https('lab-server-pharme.dhc-lab.hpi.de', '');
final annotationServerIp = Uri.https(
  'annotation-server-pharme.dhc-lab.hpi.de',
  '',
);
final annotationServerUrl = annotationServerIp.replace(path: 'api/v1');
final labServerUrl = labServerIp.replace(path: 'api/v1');
final keycloakUrl = labServerIp;
final cpicMaxCacheTime = Duration(days: 90);
const maxCachedMedications = 10;
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult';
