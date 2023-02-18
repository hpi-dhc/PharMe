import 'package:freezed_annotation/freezed_annotation.dart';

import '../../module.dart';

part 'cubit.freezed.dart';

class DrugCubit extends Cubit<DrugState> {
  DrugCubit(this._drug) : super(DrugState.initial()) {
    emit(DrugState.loaded(_drug, isStarred: _drug.isStarred()));
  }

  final Drug _drug;

  Future<void> toggleStarred() async {
    final drug = state.whenOrNull(loaded: (drug, _) => drug);
    if (drug == null) return;

    final stars = UserData.instance.starredDrugNames ?? [];
    if (drug.isStarred()) {
      UserData.instance.starredDrugNames =
          stars.filter((element) => element != _drug.name).toList();
    } else {
      UserData.instance.starredDrugNames = stars + [_drug.name];
    }
    await UserData.save();
    emit(DrugState.loaded(drug, isStarred: drug.isStarred()));
  }
}

@freezed
class DrugState with _$DrugState {
  const factory DrugState.initial() = _InitialState;
  const factory DrugState.loading() = _LoadingState;
  const factory DrugState.loaded(Drug drug, {required bool isStarred}) =
      _LoadedState;
  const factory DrugState.error() = _ErrorState;
}
