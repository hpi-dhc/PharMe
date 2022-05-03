import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import '../../models/medication.dart';

part 'cubit.freezed.dart';

class MedicationsOverviewCubit extends Cubit<MedicationsOverviewState> {
  MedicationsOverviewCubit() : super(MedicationsOverviewState.initial());

  Future<List<Medication>> loadMedications(String value) async {
    final requestUri = annotationServerUrl.replace(
      path: 'api/v1/medications',
      queryParameters: {'search': value},
    );

    emit(MedicationsOverviewState.loading());

    final response = await http.get(requestUri);

    if (response.statusCode != 200) {
      emit(MedicationsOverviewState.error());
      return [];
    }
    return medicationsFromHTTPResponse(response);
  }

  void setState(MedicationsOverviewState state) => emit(state);
}

@freezed
class MedicationsOverviewState with _$MedicationsOverviewState {
  const factory MedicationsOverviewState.initial() = _InitialState;
  const factory MedicationsOverviewState.loading() = _LoadingState;
  const factory MedicationsOverviewState.loaded(List<Medication> medications) =
      _LoadedState;
  const factory MedicationsOverviewState.error() = _ErrorState;
}
