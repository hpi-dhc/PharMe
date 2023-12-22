import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:overlay_dialog/overlay_dialog.dart';

import '../common/module.dart';

part 'cubit.freezed.dart';

class DrugCubit extends Cubit<DrugState> {
  DrugCubit(this.activeDrugs) : super(DrugState.loaded());

  final ActiveDrugs activeDrugs;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setActivity(Drug drug, bool? value) async {
    if (value == null) return;
    emit(DrugState.loading());
    await activeDrugs.changeActivity(drug.name, value);
    emit(DrugState.loaded());
  }

  Future<void> createAndSharePdf(Drug drug, BuildContext context) async {
    DialogHelper().show(
      context,
      DialogWidget.progress(style: DialogStyle.adaptive)
    );
    emit(DrugState.loading());
    await sharePdf(drug, context);
    emit(DrugState.loaded());
    // ignore: use_build_context_synchronously
    DialogHelper().hide(context);
  }
}

@freezed
class DrugState with _$DrugState {
  const factory DrugState.loading() = _LoadingState;
  const factory DrugState.loaded() = _LoadedState;
}
