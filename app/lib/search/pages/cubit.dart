import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import '../../medications/models/medication.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial());

  Timer? searchTimeout;
  final duration = Duration(milliseconds: 500);

  void loadMedications(String value) {
    if (value.isEmpty) {
      emit(
        SearchState.loaded([]),
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
        emit(SearchState.loading());

        final response = await http.get(requestUri);
        if (response.statusCode != 200) {
          emit(SearchState.error());
          return;
        }
        final medications = medicationsFromHTTPResponse(response);

        emit(SearchState.loaded(medications));
      },
    );
  }

  void setState(SearchState state) => emit(state);
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _InitialState;
  const factory SearchState.loading() = _LoadingState;
  const factory SearchState.loaded(List<Medication> medications) = _LoadedState;
  const factory SearchState.error() = _ErrorState;
}
