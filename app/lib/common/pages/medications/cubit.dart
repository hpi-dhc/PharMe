import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

import '../../module.dart';

part 'cubit.freezed.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  MedicationsCubit(this._id) : super(MedicationsState.initial()) {
    loadMedications();
  }

  final int _id;

  Future<void> loadMedications() async {
    emit(MedicationsState.loading());
    final response = await sendRequest();
    if (response == null) {
      emit(MedicationsState.error());
      return;
    }
    final medication = medicationWithGuidelinesFromHTTPResponse(response);
    emit(MedicationsState.loaded(medication));
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
        queryParameters: {'withGuidelines': 'true'},
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
