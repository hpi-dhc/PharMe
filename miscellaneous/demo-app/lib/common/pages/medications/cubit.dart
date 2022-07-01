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
    await CachedMedications.cache(medication);
    emit(MedicationsState.loaded(medication));
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
      path: 'api/v1/medications',
      queryParameters: {'onlyIds': 'true'},
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
        queryParameters: {'getGuidelines': 'true'},
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