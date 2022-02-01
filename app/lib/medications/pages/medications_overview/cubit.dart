import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../models/medication.dart';

part 'cubit.freezed.dart';

class MedicationsOverviewCubit extends Cubit<MedicationsOverviewState> {
  MedicationsOverviewCubit() : super(MedicationsOverviewState.initial()) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    emit(MedicationsOverviewState.loading());
    final response = await http.get(Uri.parse('http://localhost:3000/rxnorm'));

    if (response.statusCode == 200) {
      final list =
          (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      final medications = list.map(Medication.fromJson).toList();
      emit(MedicationsOverviewState.loaded(medications));
    } else {
      emit(MedicationsOverviewState.error());
    }
  }
}

@freezed
class MedicationsOverviewState with _$MedicationsOverviewState {
  const factory MedicationsOverviewState.initial() = _InitialState;
  const factory MedicationsOverviewState.loading() = _LoadingState;
  const factory MedicationsOverviewState.loaded(List<Medication> medications) =
      _LoadedState;
  const factory MedicationsOverviewState.error() = _ErrorState;
}
