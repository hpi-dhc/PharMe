import 'package:url_launcher/url_launcher.dart';

Uri anniUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8000', 'api/v1/$slug');
Uri labServerUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8081', 'api/v1/$slug');
Uri keycloakUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:28080', 'auth/$slug');

// Note that sending emails will not work on the iPhone Simulator since it does
// not have any email application installed.
String contactEmailAddress = 'ehivepgx@mssm.edu';
// Workaround according to https://pub.dev/packages/url_launcher#encoding-urls
String? _encodeQueryParameters(Map<String, String> params) {
return params.entries
    .map((entry) =>
      '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}'
    ).join('&');
}
Future<void> sendEmail({
  String subject = '',
  String body = '',
}) async {
  await launchUrl(
    Uri(
      scheme: 'mailto',
      path: contactEmailAddress,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    ),
  );
}

final geneticInformationUrl = Uri.https(
  'medlineplus.gov',
  '/genetics/understanding/',
);

Future<void> openFurtherGeneticInformation() async =>
  launchUrl(geneticInformationUrl);

final cpicMaxCacheTime = Duration(days: 90);
const maxCachedDrugs = 10;
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult,lookupkey';

const drugInteractionIndicator = '*';
const drugInteractionIndicatorName = 'asterisk';
