import 'package:freezed_annotation/freezed_annotation.dart';

import '../../module.dart';

part 'cubit.freezed.dart';

class DrugCubit extends Cubit<DrugState> {
  DrugCubit(this._drug) : super(DrugState.initial()) {
    emit(DrugState.loaded(_drug, isActive: _drug.isActive()));
  }

  final Drug _drug;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setActivity(bool? value) async {
    if (value == null) return;
    final drug = state.whenOrNull(loaded: (drug, _) => drug);
    if (drug == null) return;

    final active = UserData.instance.activeDrugNames ?? [];
    if (value) {
      UserData.instance.activeDrugNames = active + [_drug.name];
    } else {
      UserData.instance.activeDrugNames =
          active.filter((element) => element != _drug.name).toList();
    }
    await UserData.save();
    emit(DrugState.loaded(drug, isActive: value));
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
