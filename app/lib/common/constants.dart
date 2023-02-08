import 'package:url_launcher/url_launcher.dart';

Uri anniUrl([String slug = '']) => Uri.http('localhost:3001', 'api/v1/$slug');
Uri labServerUrl([String slug = '']) =>
    Uri.https('lab-server-pharme.dhc-lab.hpi.de', 'api/v1/$slug');
Uri keycloakUrl([String slug = '']) =>
    Uri.https('keycloak-pharme.dhc-lab.hpi.de', slug);

// Note that sending emails will not work on the iPhone Simulator since it does
// not have any email application installed.
String _mailContact = 'pgx-app-validation-study@lists.myhpi.de';
Future<void> sendEmail({String subject = ''}) async {
  await launchUrl(Uri(
      scheme: 'mailto',
      path: _mailContact,
      queryParameters: {'subject': subject}));
}

final cpicMaxCacheTime = Duration(days: 90);
const maxCachedDrugs = 10;
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult,lookupkey';
