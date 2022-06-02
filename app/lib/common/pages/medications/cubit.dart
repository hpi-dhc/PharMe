import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

import '../../models/medication/cached_medications.dart';
import '../../module.dart';

part 'cubit.freezed.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  MedicationsCubit(this._id) : super(MedicationsState.initial()) {
    loadMedications();
  }

  final int _id;

  Future<void> loadMedications() async {
    emit(MedicationsState.loading());
    final isOnline = await hasConnectionTo(annotationServerUrl.authority);
    if (!isOnline) {
      _findCachedMedication(_id);
      return;
    }
    final response = await sendRequest();
    if (response == null) {
      emit(MedicationsState.error());
      return;
    }
    final medication = medicationWithGuidelinesFromHTTPResponse(response);
    await _cacheMedication(medication);
    emit(MedicationsState.loaded(medication));
  }

  Future<void> _cacheMedication(MedicationWithGuidelines medication) async {
    CachedMedications.instance.medications ??= [];

    // equality for a medication is defined as same name and same value for the guidelines
    if (CachedMedications.instance.medications!.contains(medication)) return;

    // if there is a medication with the same name already cached, then update its guidelines
    final index = CachedMedications.instance.medications!
        .indexWhere((element) => element.name == medication.name);
    if (index > -1) {
      final filteredMedication = filterUserGuidelines(medication);
      CachedMedications.instance.medications![index] = filteredMedication;
      await CachedMedications.save();
      return;
    }

    // if the medication is completely new to the list
    CachedMedications.instance.medications!.add(medication);
    await CachedMedications.save();
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

  Future<Response?> sendRequest() async {
    final requestIdsUri = annotationServerUrl.replace(
      path: 'api/v1/medications/ids',
    );
    final idsResponse = await get(requestIdsUri);
    if (idsResponse.statusCode != 200) {
      emit(MedicationsState.error());
      return null;
    }
    final randomIds = idsFromHTTPResponse(idsResponse).sample(2);
    randomIds.add(_id);
    randomIds.shuffle();
    Response? response;
    for (final id in randomIds) {
      final requestMedicationUri = annotationServerUrl.replace(
        path: 'api/v1/medications/$id',
      );

      final tempResponse = await get(requestMedicationUri);
      if (tempResponse.statusCode != 200) {
        emit(MedicationsState.error());
        return null;
      }
      if (id == _id) response = tempResponse;
    }
    return response;
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
