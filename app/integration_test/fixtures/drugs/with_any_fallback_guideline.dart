import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final drugWithAnyFallbackGuideline = Drug(
  id: '658df37b3aa92cbd80bbe352',
  version: 1,
  name: 'warfarin',
  rxNorm: 'RxNorm:11289',
  annotations: DrugAnnotations(
    drugclass: 'Blood thinner',
    indication: 'Warfarin is used to prevent and treat blood clots.',
    brandNames: ['Coumadin', 'Jantoven'],
  ),
  guidelines: [
    Guideline(
      id: '66b50b2433cbe5c07ee3101d',
      version: 4,
      lookupkey: {
        'CYP2C9': ['*'],
        'VKORC1': ['*'],
        'CYP4F2': ['*'],
        'CYP2C': ['*'],
      },
      externalData: [
        GuidelineExtData(
          source: 'CPIC',
          guidelineName: 'CPIC® Guideline for Pharmacogenetics-Guided Warfarin Dosing',
          guidelineUrl: 'https://cpicpgx.org/guidelines/guideline-for-warfarin-and-cyp2c9-and-vkorc1/',
          implications: {
            'CYP2C9': 'No implication',
            'VKORC1': 'No implication',
            'CYP4F2': 'No implication',
            'CYP2C': 'No implication',
          },
          recommendation: 'No recommendation',
          comments: null,
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'More information is needed to calculate your warfarin dose.',
        recommendation: 'Consult your pharmacist or doctor for more information.',
        warningLevel: WarningLevel.yellow,
      ),  
    ),
  ],
);