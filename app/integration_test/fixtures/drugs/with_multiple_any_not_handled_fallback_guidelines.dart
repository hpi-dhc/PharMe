import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final drugWithMultipleAnyNotHandledFallbackGuidelines = Drug(
  id: '6686a865826414ec5b05c44e',
  version: 1,
  name: 'pazopanib',
  rxNorm: 'RxNorm:714438',
  annotations: DrugAnnotations(
    drugclass: 'Anti-cancer',
    indication: 'Pazopanib is used to treat cancer.',
    brandNames: ['Votrient'],
  ),
  guidelines: [
    Guideline(
      id: '66b50b2433cbe5c07ee31651',
      version: 1,
      lookupkey: {
        'HLA-B': ['~'],
        'UGT1A1': ['Poor Metabolizer'],
      },
      externalData: [
        GuidelineExtData(
          source: 'CPIC',
          guidelineName: 'Table of Pharmacogenetic Associations (Section 2)',
          guidelineUrl: 'https://www.fda.gov/medical-devices/precision-medicine/table-pharmacogenetic-associations#section2',
          implications: {
            'HLA-B': 'Standard procedure',
            'UGT1A1': 'Results in higher adverse reaction risk (hyperbilirubinemia).',
          },
          recommendation: 'Might be included in implication text (imported from FDA, source only states one text per guideline)',
          comments: null,
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'You have an increased risk for side effects.',
        recommendation: 'You can still use pazopanib at standard dose. Consult your pharmacist or doctor for more information.',
        warningLevel: WarningLevel.yellow,
      ),  
    ),
  ],
);