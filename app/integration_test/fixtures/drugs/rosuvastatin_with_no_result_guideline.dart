import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/drug/guideline.dart';
import 'package:app/common/models/drug/warning_level.dart';

final rosuvastatinWithNoResultGuidelines = Drug(
  id: '6407768c92a4868065b6d18e',
  version: 1,
  name: 'rosuvastatin',
  rxNorm: 'RxNorm:301542',
  annotations: DrugAnnotations(
    drugclass: 'Anti-cholesterol',
    indication: 'Statins lower high cholesterol and triglyceride levels and reduce risk of heart related health conditions.',
    brandNames: ['Crestor', 'Ezallor', 'Roszet'],
  ),
  guidelines: [
    Guideline(
      id: '64552859a1b68082babc8e09',
      version: 1,
      lookupkey: {
        'ABCG2': ['No Result'],
        'SLCO1B1': ['Normal Function'],
      },
      externalData: [
        GuidelineExtData(
          source: 'CPIC',
          guidelineName: 'SLCO1B1, ABCG2, CYP2C9, and Statins',
          guidelineUrl: 'https://cpicpgx.org/guidelines/cpic-guideline-for-statins/',
          implications: {
            'ABCG2': 'n/a',
            'SLCO1B1': 'Typical myopathy risk and statin exposure',
          },
          recommendation: 'Based on SLCO1B1 status, prescribe desired starting dose and adjust doses based on disease-specific guidelines. ABCG2 genotype result is not available.',
          comments: 'The potential for drug-drug interactions and dose limits based on renal and hepatic function and ancestry should be evaluated prior to initiating a statin.',
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'You have a normal risk for side effects. (One missing)',
        recommendation: 'You can use rosuvastatin at standard dose. Consult your pharmacist or doctor for more information. (One missing)',
        warningLevel: WarningLevel.green,
      ),  
    ),
    Guideline(
      id: '64552859a1b68082babc8e14',
      version: 1,
      lookupkey: {
        'ABCG2': ['Normal Function'],
        'SLCO1B1': ['Normal Function'],
      },
      externalData: [
        GuidelineExtData(
          source: 'CPIC',
          guidelineName: 'SLCO1B1, ABCG2, CYP2C9, and Statins',
          guidelineUrl: 'https://cpicpgx.org/guidelines/cpic-guideline-for-statins/',
          implications: {
            'ABCG2': 'Typical myopathy risk and rosuvastatin exposure',
            'SLCO1B1': 'Typical myopathy risk and statin exposure',
          },
          recommendation: 'Based on SLCO1B1 status, prescribe desired starting dose and adjust doses based on disease-specific guidelines. ABCG2 genotype result is not available.',
          comments: 'The potential for drug-drug interactions and dose limits based on renal and hepatic function and ancestry should be evaluated prior to initiating a statin.',
        ),
      ],
      annotations: GuidelineAnnotations(
        implication: 'You have a normal risk for side effects. (Both normal)',
        recommendation: 'You can use rosuvastatin at standard dose. Consult your pharmacist or doctor for more information. (Both normal)',
        warningLevel: WarningLevel.green,
      ),  
    ),
  ],
);