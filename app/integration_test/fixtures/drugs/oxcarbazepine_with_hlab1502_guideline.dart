import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final oxcarbazepineWithHlab1502Guideline = Drug(
  id: '6407768c92a4868065b6ceb6',
  version: 1,
  name: 'oxcarbazepine',
  rxNorm: 'RxNorm:32624',
  annotations: DrugAnnotations(
    drugclass: 'Anti-seizure',
    indication: 'Oxcarbazepine is an anti-epileptic used to prevent seizures.',
    brandNames: ['Oxtellar', 'Trileptal'],
  ),
  guidelines: [
    Guideline(
      id: '64552859a1b68082babc8dc6',
      version: 1,
      lookupkey: {
        'HLA-B': ['*15:02 negative'],
      },
      externalData: [
        GuidelineExtData(
          source: 'CPIC',
          guidelineName: 'HLA-A, HLA-B and Carbamazepine and Oxcarbazepine',
          guidelineUrl: 'https://cpicpgx.org/guidelines/guideline-for-carbamazepine-and-hla-b/',
          implications: {
            'HLA-B': 'Normal risk of oxcarbazepine-induced SJS/TEN',
          },
          recommendation: 'Use oxcarbazepine per standard dosing guidelines.',
          comments: 'n/a',
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'You have a normal risk for side effects.',
        recommendation: 'You can use oxcarbazepine at standard dose. Consult your pharmacist or doctor for more information.',
        warningLevel: WarningLevel.green,
      ),  
    ),
  ],
);