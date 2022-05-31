import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../module.dart';

part 'cubit.freezed.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  MedicationsCubit(this._id) : super(MedicationsState.initial()) {
    loadMedications();
  }

  final int _id;

  Future<void> loadMedications() async {
    emit(MedicationsState.loading());
    final response = await sendWithRandomRequests();
    if (response == null){
      emit(MedicationsState.error());
    }
    else {
      final medication = medicationWithGuidelinesFromHTTPResponse(response);
      emit(MedicationsState.loaded(medication));
    }
  }

  Future<http.Response> sendRequest(Uri requestUri) async {
    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      emit(MedicationsState.error());
    }
    return response;
  }

  Future<http.Response?> sendWithRandomRequests() async {
    final requestIdsUri = annotationServerUrl.replace(
      path: 'api/v1/medications/ids',
    );
    final idsResponse = await http.get(requestIdsUri);
    final idsMapList = jsonDecode(idsResponse.body) as List<dynamic>;

    final idList = [];
    for (final element in idsMapList) {
      idList.add(element['id']);
    }

    final randomIds = idList.sample(2);
    randomIds.add(_id);
    randomIds.shuffle();
    http.Response? response;
    for (final id in randomIds) {
      final requestMedicationUri = annotationServerUrl.replace(
        path: 'api/v1/medications/$id',
      );
      final tempResponse = await sendRequest(requestMedicationUri);
      if (id == _id) {
        response = tempResponse;
      }
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
