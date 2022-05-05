import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import '../../models/medication.dart';

part 'cubit.freezed.dart';

class MedicationsOverviewCubit extends Cubit<MedicationsOverviewState> {
  MedicationsOverviewCubit() : super(MedicationsOverviewState.initial());

  Timer? searchTimeout;
  final duration = Duration(milliseconds: 500);

  void loadMedications(String value) {
    if (value.isEmpty) {
      emit(
        MedicationsOverviewState.loaded([]),
      );
      if (searchTimeout != null) {
        searchTimeout!.cancel();
      }
      return;
    }
    if (searchTimeout != null) {
      searchTimeout!.cancel();
    }
    searchTimeout = Timer(
      duration,
      () async {
        final requestUri = annotationServerUrl.replace(
          path: 'api/v1/medications',
          queryParameters: {'search': value},
        );
        emit(MedicationsOverviewState.loading());

        final response = await http.get(requestUri);
        if (response.statusCode != 200) {
          emit(MedicationsOverviewState.error());
          return;
        }
        final medications = medicationsFromHTTPResponse(response);

        emit(MedicationsOverviewState.loaded(medications));
      },
    );
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
