import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final pazopanibHlab5701PositiveUgt1a1PoorGuideline = Guideline(
  id: '6686a865826414ec5b05c436',
  version: 1,
  lookupkey: {
    'HLA-B': ['*57:01 positive'],
    'UGT1A1': ['Poor Metabolizer'],
  },
  externalData: [
    GuidelineExtData(
      source: 'FDA',
      guidelineName: 'Table of Pharmacogenetic Associations (Section 2)',
      guidelineUrl: 'https://www.fda.gov/medical-devices/precision-medicine/table-pharmacogenetic-associations#section2',
      implications: {
        'HLA-B': 'May result in higher adverse reaction risk (liver enzyme elevations). Monitor liver function tests regardless of genotype.',
        'UGT1A1': 'Results in higher adverse reaction risk (hyperbilirubinemia).',
      },
      recommendation: 'Might be included in implication text (imported from FDA, source only states one text per guideline)',
      comments: null,
    ),
  ],
  annotations: GuidelineAnnotations(
    implication: 'You have an increased risk for side effects. (Test case 1)',
    recommendation: 'You can still use pazopanib at standard dose. Consult your pharmacist or doctor for more information. (Test case 1)',
    warningLevel: WarningLevel.yellow,
  ),  
);