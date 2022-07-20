import 'package:comprehension_measurement/scio.dart';

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
final supabaseConfig = SupabaseConfig(
  'https://xrnczlpeghrewcseaxyq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhybmN6bHBlZ2hyZXdjc2VheHlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTI5NjIzNTksImV4cCI6MTk2ODUzODM1OX0.3SPL2iHbDRS4m42n6UlOIuV8tFMShi7b9Mzh9l8E4Gs',
);
