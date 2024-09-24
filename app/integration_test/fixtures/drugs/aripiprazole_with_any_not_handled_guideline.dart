import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

import '../guidelines/aripiprazole_cyp2d6_poor.dart';

final aripiprazoleWithAnyNotHandledFallbackGuideline = Drug(
  id: '6492f8e9918ddcae7349c30c',
  version: 1,
  name: 'aripiprazole',
  rxNorm: 'RxNorm:89013',
  annotations: DrugAnnotations(
    drugclass: 'Anti-psychotic',
    indication: 'Aripiprazole is used to manage and treat schizophrenia, major depressive disorder, and other psychotic disorders.',
    brandNames: ['Abilify'],
  ),
  guidelines: [
    aripiprazoleCyp2d6PoorGuideline,
    Guideline(
      id: '66b50b2433cbe5c07ee311d7',
      version: 1,
      lookupkey: {
        'CYP2D6': ['~'],
      },
      externalData: [
        GuidelineExtData(
          source: 'FDA',
          guidelineName: 'Table of Pharmacogenetic Associations (Section 1)',
          guidelineUrl: 'https://www.fda.gov/medical-devices/precision-medicine/table-pharmacogenetic-associations#section1',
          implications: {
            'CYP2D6': 'Standard procedure',
          },
          recommendation: 'Might be included in implication text (imported from FDA, source only states one text per guideline)',
          comments: null,
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'Your phenotype does not have a clinically significant influence on aripiprazole.',
        recommendation: 'You can use aripiprazole at standard dose. Consult your pharmacist or doctor for more information.',
        warningLevel: WarningLevel.green,
      ),  
    ),
  ],
);