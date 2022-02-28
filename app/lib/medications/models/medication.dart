import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication(int id, String name) = _Medication;
  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}
