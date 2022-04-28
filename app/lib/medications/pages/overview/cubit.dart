import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/medication.dart';

part 'cubit.freezed.dart';

class MedicationsOverviewCubit extends Cubit<MedicationsOverviewState> {
  MedicationsOverviewCubit() : super(MedicationsOverviewState.initial());

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
