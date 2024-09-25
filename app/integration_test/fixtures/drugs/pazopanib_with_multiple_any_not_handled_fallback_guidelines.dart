import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

import '../guidelines/pazopanib_hlab5701_positive_ugt1a1_poor.dart';

final pazopanibWithMultipleAnyNotHandledFallbackGuidelines = Drug(
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
    pazopanibHlab5701PositiveUgt1a1PoorGuideline,
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
        implication: 'You have an increased risk for side effects. (Test case 2)',
        recommendation: 'You can still use pazopanib at standard dose. Consult your pharmacist or doctor for more information. (Test case 2)',
        warningLevel: WarningLevel.yellow,
      ),  
    ),
    Guideline(
      id: '66b50b2433cbe5c07ee31657',
      version: 1,
      lookupkey: {
        'HLA-B': ['*57:01 positive'],
        'UGT1A1': ['~'],
      },
      externalData: [
        GuidelineExtData(
          source: 'FDA',
          guidelineName: 'Table of Pharmacogenetic Associations (Section 2)',
          guidelineUrl: 'https://www.fda.gov/medical-devices/precision-medicine/table-pharmacogenetic-associations#section2',
          implications: {
            'HLA-B': 'May result in higher adverse reaction risk (liver enzyme elevations). Monitor liver function tests regardless of genotype.',
            'UGT1A1': 'Standard procedure',
          },
          recommendation: 'Might be included in implication text (imported from FDA, source only states one text per guideline)',
          comments: null,
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'You may have an increased risk for side effects. (Test case 3)',
        recommendation: 'You can still use pazopanib at standard dose. Consult your pharmacist or doctor for more information. (Test case 3)',
        warningLevel: WarningLevel.yellow,
      ),  
    ),
    Guideline(
      id: '66b50b2433cbe5c07ee3165d',
      version: 1,
      lookupkey: {
        'HLA-B': ['~'],
        'UGT1A1': ['~'],
      },
      externalData: [
        GuidelineExtData(
          source: 'FDA',
          guidelineName: 'Table of Pharmacogenetic Associations (Section 2)',
          guidelineUrl: 'https://www.fda.gov/medical-devices/precision-medicine/table-pharmacogenetic-associations#section2',
          implications: {
            'HLA-B': 'Standard procedure',
            'UGT1A1': 'Standard procedure',
          },
          recommendation: 'Might be included in implication text (imported from FDA, source only states one text per guideline)',
          comments: null,
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'Your phenotype does not have a clinically significant influence on pazopanib. (Test case 4)',
        recommendation: 'You can use pazopanib at standard dose. Consult your pharmacist or doctor for more information. (Test case 4)',
        warningLevel: WarningLevel.green,
      ),  
    ),
  ],
);