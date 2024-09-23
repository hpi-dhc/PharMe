import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final aripiprazoleCyp2d6PoorGuideline = Guideline(
  id: '6492f8e9918ddcae7349c304',
  version: 1,
  lookupkey: {
    'CYP2D6': ['0.0'],
  },
  externalData: [
    GuidelineExtData(
      source: 'FDA',
      guidelineName: 'Table of Pharmacogenetic Associations (Section 1)',
      guidelineUrl: 'https://www.fda.gov/medical-devices/precision-medicine/table-pharmacogenetic-associations#section1',
      implications: {
        'CYP2D6': 'Results in higher systemic concentrations and higher adverse reaction risk. Dosage adjustment is recommended. Refer to FDA labeling for specific dosing recommendations.',
      },
      recommendation: 'Might be included in implication text (imported from FDA, source only states one text per guideline)',
      comments: null,
    ),
  ],
  annotations: GuidelineAnnotations(
    implication: 'You break down aripiprazole slower than expected. You have an increased risk for side effects.',
    recommendation: 'Aripiprazole may be used at a lower dose. Consult your pharmacist or doctor for more information.',
    warningLevel: WarningLevel.yellow,
  ),  
);