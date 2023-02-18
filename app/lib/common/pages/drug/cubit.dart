import 'package:freezed_annotation/freezed_annotation.dart';

import '../../module.dart';

part 'cubit.freezed.dart';

class DrugCubit extends Cubit<DrugState> {
  DrugCubit(this._drug) : super(DrugState.initial()) {
    emit(DrugState.loaded(_drug, isActive: _drug.isActive()));
  }

  final Drug _drug;

  Future<void> toggleActive() async {
    final drug = state.whenOrNull(loaded: (drug, _) => drug);
    if (drug == null) return;

    final active = UserData.instance.activeDrugNames ?? [];
    if (drug.isActive()) {
      UserData.instance.activeDrugNames =
          active.filter((element) => element != _drug.name).toList();
    } else {
      UserData.instance.activeDrugNames = active + [_drug.name];
    }
    await UserData.save();
    emit(DrugState.loaded(drug, isActive: drug.isActive()));
  }
}

@freezed
class DrugState with _$DrugState {
  const factory DrugState.initial() = _InitialState;
  const factory DrugState.loading() = _LoadingState;
  const factory DrugState.loaded(Drug drug, {required bool isActive}) =
      _LoadedState;
  const factory DrugState.error() = _ErrorState;
}
