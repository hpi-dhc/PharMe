import 'package:freezed_annotation/freezed_annotation.dart';

import 'medication.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication(
          int id, String name, String description, List<String> synonyms) =
      _Medication;
  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}
