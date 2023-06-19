import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/module.dart';
import '../../common/pages/drug/cubit.dart';

part 'cubit.freezed.dart';

class DrugSelectionPageCubit extends Cubit<DrugSelectionPageState> {
  DrugSelectionPageCubit() : super(DrugSelectionPageState.stable());

  // ignore: avoid_positional_boolean_parameters
  Future<void> updateDrugActivity(Drug drug, bool? value) async {
    if (value == null) return;
    emit(DrugSelectionPageState.updating());
    await setDrugActivity(drug, value);
    emit(DrugSelectionPageState.stable());
  }
}

@freezed
class DrugSelectionPageState with _$DrugSelectionPageState {
  const factory DrugSelectionPageState.stable() = _StableState;
  const factory DrugSelectionPageState.updating() = _UpdatingState;
}
