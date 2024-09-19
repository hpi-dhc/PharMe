import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final drugWithProperGuideline = Drug(
  id: '6407768b92a4868065b6c466',
  version: 1,
  name: 'ibuprofen',
  rxNorm: 'RxNorm:5640',
  annotations: DrugAnnotations(
      drugclass: 'Non-steroidal anti-inflammatory drug (NSAID)',
      indication: 'Ibuprofen is used to treat pain, fever, and inflammation.',
      brandNames: [
        'Advil',
        'Ibutab',
        'Motrin',
        'Neoprofen',
        'Proprinal',
        'Vicoprofen',
      ]),
  guidelines: [
    Guideline(
      id: '64552859a1b68082babc8c31',
      version: 1,
      lookupkey: {
        'CYP2C9': ['2.0']
      },
      externalData: [
        GuidelineExtData(
            source: 'CPIC',
            guidelineName: 'CYP2C9 and NSAIDs',
            guidelineUrl: 'https://cpicpgx.org/guidelines/cpic-guideline-for-nsaids-based-on-cyp2c9-genotype/',
            implications: {'CYP2C9': 'Normal metabolism'},
            recommendation: 'Initiate therapy with recommended starting dose. In accordance with the prescribing information, use the lowest effective dosage for shortest duration consistent with individual patient treatment goals.',
            comments: 'n/a')
      ],
      annotations: GuidelineAnnotations(
          implication: 'You break down ibuprofen as expected.',
          recommendation: 'You can use ibuprofen at standard dose. Consult your pharmacist or doctor for more information.',
          warningLevel: WarningLevel.green,
      ),
    ),
  ],
);
