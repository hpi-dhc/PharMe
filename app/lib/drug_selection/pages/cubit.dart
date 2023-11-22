import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/module.dart';

part 'cubit.freezed.dart';

class DrugSelectionPageCubit extends Cubit<DrugSelectionPageState> {
  DrugSelectionPageCubit(this.activeDrugs) :
    super(DrugSelectionPageState.stable());

  final ActiveDrugs activeDrugs;

  // ignore: avoid_positional_boolean_parameters
  Future<void> updateDrugActivity(Drug drug, bool? value) async {
    if (value == null) return;
    emit(DrugSelectionPageState.updating());
    await activeDrugs.changeActivity(drug.name, value);
    emit(DrugSelectionPageState.stable());
  }
}

@freezed
class DrugSelectionPageState with _$DrugSelectionPageState {
  const factory DrugSelectionPageState.stable() = _StableState;
  const factory DrugSelectionPageState.updating() = _UpdatingState;
}
