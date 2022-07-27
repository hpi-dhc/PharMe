import 'package:scio/scio.dart';

Uri annotationServerUrl([String slug = '']) =>
    Uri.https('annotation-server-pharme.dhc-lab.hpi.de', 'api/v1/$slug');
Uri labServerUrl([String slug = '']) =>
    Uri.https('lab-server-pharme.dhc-lab.hpi.de', 'api/v1/$slug');
Uri keycloakUrl([String slug = '']) => Uri.https('keycloak.k8s.kunst.me', slug);

final cpicMaxCacheTime = Duration(days: 90);
const maxCachedMedications = 10;
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult';
final supabaseConfig = SupabaseConfig(
  'https://xrnczlpeghrewcseaxyq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhybmN6bHBlZ2hyZXdjc2VheHlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTI5NjIzNTksImV4cCI6MTk2ODUzODM1OX0.3SPL2iHbDRS4m42n6UlOIuV8tFMShi7b9Mzh9l8E4Gs',
);
