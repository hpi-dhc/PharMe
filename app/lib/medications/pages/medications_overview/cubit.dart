import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cubit.freezed.dart';

class MedicationsOverviewCubit extends Cubit<MedicationsOverviewState> {
  MedicationsOverviewCubit() : super(MedicationsOverviewState.initial()) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    emit(MedicationsOverviewState.loading());
    // TODO(Benjamin-Frost): Load actual content
    await Future.delayed(Duration(seconds: 3));
    emit(MedicationsOverviewState.loaded());
  }
}

@freezed
class MedicationsOverviewState with _$MedicationsOverviewState {
  const factory MedicationsOverviewState.initial() = _InitialState;
  const factory MedicationsOverviewState.loading() = _LoadingState;
  const factory MedicationsOverviewState.loaded() = _LoadedState;
}
