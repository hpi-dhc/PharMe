import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../module.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication(
    int id,
    String name,
    String description,
    String? drugclass,
    String? indication,
  ) = _Medication;
  factory Medication.fromJson(dynamic json) => _$MedicationFromJson(json);
}

@HiveType(typeId: 8)
@JsonSerializable()
class MedicationWithGuidelines {
  MedicationWithGuidelines({
    required this.id,
    required this.name,
    this.description,
    this.pharmgkbId,
    this.rxcui,
    this.synonyms,
    this.drugclass,
    this.indication,
    required this.guidelines,
    this.isCritical = false,
  });
  factory MedicationWithGuidelines.fromJson(dynamic json) =>
      _$MedicationWithGuidelinesFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? pharmgkbId;

  @HiveField(4)
  String? rxcui;

  @HiveField(5)
  List<String>? synonyms;

  @HiveField(6)
  String? drugclass;

  @HiveField(7)
  String? indication;

  @HiveField(8)
  List<Guideline> guidelines;

  // Indicates whether this medication is used in the reports
  @HiveField(9)
  bool isCritical;

  @override
  bool operator ==(other) =>
      other is MedicationWithGuidelines &&
      name == other.name &&
      guidelines.contentEquals(other.guidelines);

  @override
  int get hashCode => hashValues(name, guidelines);

  Medication toMedication() {
    return Medication(
      id,
      name,
      description ?? '',
      drugclass,
      indication,
    );
  }

  static final fakeData = [
    MedicationWithGuidelines(
      id: 1,
      name: 'Ibuprofen',
      description: 'Lorem ipsum',
      pharmgkbId: 'PA449957',
      rxcui: '5640',
      synonyms: ['Ibuprofen'],
      drugclass: 'Pain killer',
      indication: 'Ibuprofen is used to treat pain and arthritis.',
      guidelines: [
        Guideline(
          id: 1,
          implication:
              'You have normal CYP2C9 gene function. This makes you activate Ibuprofen as normal.',
          recommendation:
              'You can use Ibuprofen at standard doses. Consult your doctor for more information.',
          warningLevel: 'ok',
          cpicRecommendation:
              'Initiate therapy with recommended starting dose. In accordance with the prescribing information, use the lowest effective dosage for shortest duration consistent with individual patient treatment goals.',
          cpicImplication: 'Normal metabolism',
          cpicClassification: 'Strong',
          cpicComment: null,
          cpicGuidelineUrl:
              'https://cpicpgx.org/guidelines/cpic-guideline-for-nsaids-based-on-cyp2c9-genotype/',
          phenotype: Phenotype(
            id: 1,
            cpicConsulationText:
                'This result signifies that the patient has two copies of a normal function allele. Based on the genotype result, this patient is predicted to be a CYP2C9 Normal metabolizer. Based only on the CYP2C9 genotype, there is no reason to adjust the dose of most medications that are affected by CYP2C9. Please consult a clinical pharmacist for more specific information about how CYP2C9 function influences drug dosing.',
            geneResult: GeneResult(id: 1, name: 'Normal Metabolizer'),
            geneSymbol: GeneSymbol(id: 2, name: 'CYP2C9'),
          ),
        ),
        Guideline(
          id: 1,
          implication:
              'You have decreased CYP2C9 gene function. This makes your body slow in clearing Ibuprofen from your system.',
          recommendation:
              'Ibuprofen may be used at a different dose. Consult your doctor for more informaton.',
          warningLevel: 'danger',
          cpicRecommendation:
              'Initiate therapy with 25-50% of the lowest recommended starting dose. Titrate dose upward to clinical effect or 25-50% of the maximum recommended dose with caution. In accordance with the prescribing information, use the lowest effective dosage for shortest duration consistent with individual patient treatment goals. Upward dose titration should not occur until after steady state is reached (at least 8 days for celecoxib after first dose in PMs). Carefully monitor adverse events such as blood pressure and kidney function during course of therapy. Alternatively, consider an alternate therapy not metabolized by CYP2C9 or not significantly impacted by CYP2C9 genetic variants in vivo.',
          cpicImplication:
              'Significantly reduced metabolism and prolonged half-life; higher plasma concentrations may increase probability and/or severity of toxicities.',
          cpicClassification: 'Moderate',
          cpicComment:
              'Alternative therapies not primarily metabolized by CYP2C9 include aspirin, ketorolac, naproxen and sulindac. Selection of therapy will depend on individual patient treatment goals and risks for toxicity.',
          cpicGuidelineUrl:
              'https://cpicpgx.org/guidelines/cpic-guideline-for-nsaids-based-on-cyp2c9-genotype/',
          phenotype: Phenotype(
            id: 2,
            cpicConsulationText:
                'This result signifies that the patient has one copy of a decreased function allele and one copy of a no function allele. Based on the genotype result, this patient is predicted to be a CYP2C9 poor metabolizer. This patient may be at high risk for an adverse response to medications that are affected by CYP2C9. Please consult a clinical pharmacist for more specific information about how CYP2C9 intermediate metabolizer status influences drug dosing.',
            geneResult: GeneResult(id: 3, name: 'Poor Metabolizer'),
            geneSymbol: GeneSymbol(id: 4, name: 'CYP2C9'),
          ),
        ),
      ],
    ),
  ];
}
