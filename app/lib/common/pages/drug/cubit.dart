import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:overlay_dialog/overlay_dialog.dart';

import '../../module.dart';
import '../../utilities/pdf_utils.dart';

part 'cubit.freezed.dart';

class DrugCubit extends Cubit<DrugState> {
  DrugCubit() : super(DrugState.loaded());

  // ignore: avoid_positional_boolean_parameters
  Future<void> setActivity(Drug drug, bool? value) async {
    if (value == null) return;
    emit(DrugState.loading());
    await setDrugActivity(drug, value);
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
  const factory DrugState.loading() = _LoadingState;
  const factory DrugState.loaded() = _LoadedState;
}
