import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/module.dart';

part 'cubit.freezed.dart';

class DrugSelectionCubit extends Cubit<DrugSelectionState> {
  DrugSelectionCubit(this.activeDrugs) :
    super(DrugSelectionState.stable());

  final ActiveDrugs activeDrugs;

  Future<void> updateDrugActivity({
    required Drug drug,
    required bool? value,
  }) async {
    if (value == null) return;
    emit(DrugSelectionState.updating());
    await activeDrugs.changeActivity(drug.name, value);
    emit(DrugSelectionState.stable());
  }
}

@freezed
class DrugSelectionState with _$DrugSelectionState {
  const factory DrugSelectionState.stable() = _StableState;
  const factory DrugSelectionState.updating() = _UpdatingState;
}
