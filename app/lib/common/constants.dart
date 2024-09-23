import 'package:url_launcher/url_launcher.dart';

Uri anniUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8000', 'api/v1/$slug');
Uri labServerUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8081', 'api/v1/$slug');
Uri keycloakUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:28080', slug);

final geneticInformationUrl = Uri.https(
  'medlineplus.gov',
  '/genetics/understanding/',
);

Future<void> openFurtherGeneticInformation() async =>
  launchUrl(geneticInformationUrl);

final cpicMaxCacheTime = Duration(days: 90);
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult,lookupkey';

const drugInteractionIndicator = '*';
const drugInteractionIndicatorName = 'asterisk';

enum SpecialLookup {
  any,
  anyNotHandled,
  noResult,
}

extension SpecialLookupValue on SpecialLookup {
  String get value {
    final valueMap = {
      SpecialLookup.any: '*',
      SpecialLookup.anyNotHandled: '~',
      SpecialLookup.noResult: 'No Result',
    };
    return valueMap[this]!;
  }
}
