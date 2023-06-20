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
    await setDrugActivity(drug, value);
    emit(DrugState.loaded(drug, isActive: value));
  }
}

// ignore: avoid_positional_boolean_parameters
Future<void> setDrugActivity(Drug drug, bool value) async {
    final active = (UserData.instance.activeDrugNames ?? [])
        .filter((name) => name != drug.name)
        .toList();
    if (value) {
      active.add(drug.name);
    }
    UserData.instance.activeDrugNames = active;
    await UserData.save();
}

@freezed
class DrugState with _$DrugState {
  const factory DrugState.initial() = _InitialState;
  const factory DrugState.loading() = _LoadingState;
  const factory DrugState.loaded(Drug drug, {required bool isActive}) =
      _LoadedState;
  const factory DrugState.error() = _ErrorState;
}
