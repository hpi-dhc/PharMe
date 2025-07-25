import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'module.dart';

const medicationsIcon = FontAwesomeIcons.pills;
const genesIcon = FontAwesomeIcons.dna;

Uri anniUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8000', 'api/v1/$slug');

final cpicMaxCacheTime = Duration(days: 90);
const cpicLookupUrl =
    'http://vm-slosarek01.dhclab.i.hpi.de:28000/lookups.json';

const drugInteractionIndicator = '*';
const drugInteractionIndicatorName = 'asterisk';

const nonFatalTestErrorMessage = 'THIS IS A NON-FATAL TEST';
const fatalTestErrorMessage = 'THIS IS A FATAL TEST';

// For shorter uniqueness check that also does not rely on variant; also format
// HLA-A (which is currently unique) as HLA-B
const definedNonUniqueGenes = ['HLA-A', 'HLA-B'];

enum SpecialLookup {
  any,
  anyNotHandled,
  noResult,
}

const indeterminateResult = 'Indeterminate';
List<String> unknownPhenotypes(BuildContext context) => [
  indeterminateResult,
  context.l10n.general_not_tested,
];

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
