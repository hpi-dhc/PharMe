import 'package:app/common/models/drug/drug.dart';

import '../guidelines/ibuprofen_cyp2c9_normal.dart';

final ibuprofenWithProperGuideline = Drug(
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
    ibuprofenCyp2c9NormalGuideline,
  ],
);
