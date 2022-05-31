import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../models/medication/cached_medications.dart';
import '../../module.dart';

part 'cubit.freezed.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  MedicationsCubit(this._id) : super(MedicationsState.initial()) {
    loadMedications();
  }

  final int _id;

  Future<void> loadMedications() async {
    final requestUri = annotationServerUrl.replace(
      path: 'api/v1/medications/$_id',
    );
    emit(MedicationsState.loading());
    final isOnline = await hasConnectionTo(requestUri.authority);
    if (!isOnline) {
      _findCachedMedication(_id);
      return;
    }
    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      emit(MedicationsState.error());
      return;
    }
    final medication = medicationWithGuidelinesFromHTTPResponse(response);
    _cacheMedication(medication);
    emit(MedicationsState.loaded(medication));
  }

  void _cacheMedication(MedicationWithGuidelines medication) {
    CachedMedications.instance.medications ??= [];
    if (CachedMedications.instance.medications!.contains(medication)) return;
    CachedMedications.instance.medications!.add(medication);
  }

  void _findCachedMedication(int id) {
    CachedMedications.instance.medications ??= [];
    try {
      final foundMedication = CachedMedications.instance.medications!
          .firstWhere((element) => element.id == id);
      emit(MedicationsState.loaded(foundMedication));
    } catch (e) {
      emit(MedicationsState.error());
    }
  }
}

@freezed
class MedicationsState with _$MedicationsState {
  const factory MedicationsState.initial() = _InitialState;
  const factory MedicationsState.loading() = _LoadingState;
  const factory MedicationsState.loaded(MedicationWithGuidelines medication) =
      _LoadedState;
  const factory MedicationsState.error() = _ErrorState;
}
