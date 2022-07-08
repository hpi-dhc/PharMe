import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/module.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial());

  Timer? searchTimeout;
  final duration = Duration(milliseconds: 500);

  void loadMedications(String value) {
    if (value.isEmpty) {
      emit(SearchState.loaded([]));
      if (searchTimeout != null) searchTimeout!.cancel();
      return;
    }
    if (searchTimeout != null) searchTimeout!.cancel();

    searchTimeout = Timer(
      duration,
      () async {
        final medications = MedicationWithGuidelines.fakeData
            .map((e) => e.toMedication())
            .where(
              (medication) =>
                  medication.name.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();

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
