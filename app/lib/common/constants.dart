import 'package:url_launcher/url_launcher.dart';

Uri anniUrl([String slug = '']) =>
    Uri.http('hpi-annotation-service.duckdns.org', 'api/v1/$slug');

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

// For shorter uniqueness check that also does not rely on variant; also format
// HLA-A (which is currently unique) as HLA-B
const definedNonUniqueGenes = ['HLA-A', 'HLA-B'];

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
