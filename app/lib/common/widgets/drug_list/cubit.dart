import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../module.dart';

part 'cubit.freezed.dart';

class DrugListCubit extends Cubit<DrugListState> {
  DrugListCubit({
    FilterState? initialFilter,
  }) : super(DrugListState.initial()) {
    loadDrugs(filter: initialFilter);
  }

  Timer? searchTimeout;
  String searchValue = '';
  final duration = Duration(milliseconds: 500);

  void search({
    String? query,
    bool? showInactive,
    Map<WarningLevel, bool>? showWarningLevel,
  }) {
    state.whenOrNull(
      initial: loadDrugs,
      loaded: (allDrugs, filter) => emit(
        DrugListState.loaded(
          allDrugs,
          FilterState.from(
            filter,
            query: query,
            showInactive: showInactive,
            showWarningLevel: showWarningLevel,
          ),
        ),
      ),
      error: loadDrugs,
    );
  }

  Future<void> loadDrugs({
    FilterState? filter,
    bool updateIfNull = true,
    bool useCache = true,
  }) async {
    filter = filter ??
        state.whenOrNull(loaded: (_, filter) => filter) ??
        FilterState.initial();

    if (useCache) {
      final drugs = CachedDrugs.instance.drugs;
      if (drugs != null) {
        emit(DrugListState.loaded(drugs, filter));
        return;
      }
      if (!updateIfNull) {
        emit(DrugListState.error());
        return;
      }
    }

    emit(DrugListState.loading());
    try {
      await updateCachedDrugs();
      await loadDrugs(updateIfNull: false, filter: filter);
    } catch (error) {
      emit(DrugListState.error());
    }
  }

  FilterState? get filter => state.whenOrNull(loaded: (_, filter) => filter);
}

class FilterState {
  FilterState({
    required this.query,
    required this.showInactive,
    required this.showWarningLevel,
    required this.genotypeKey,
  });

  FilterState.initial()
      : this(
          query: '',
          showInactive: true,
          showWarningLevel: {
            for (var level in WarningLevel.values) level: true
          },
          genotypeKey: '',
        );

  FilterState.from(
    FilterState other, {
    String? query,
    bool? showInactive,
    Map<WarningLevel, bool>? showWarningLevel,
    String? genotypeKey,
  }) : this(
          query: query ?? other.query,
          showInactive: showInactive ?? other.showInactive,
          showWarningLevel: {
            for (var level in WarningLevel.values)
              level: showWarningLevel?[level] ?? other.showWarningLevel[level]!
          },
          genotypeKey: genotypeKey ?? other.genotypeKey,
        );

  FilterState.forGenotypeKey(String genotypeKey)
      : this(
          query: '',
          showInactive: true,
          showWarningLevel: {
            for (var level in WarningLevel.values) level: true
          },
          genotypeKey: genotypeKey,
        );

  final String query;
  final bool showInactive;
  final Map<WarningLevel, bool> showWarningLevel;
  final String genotypeKey;

  bool isAccepted(Drug drug, ActiveDrugs activeDrugs, {
    required bool useDrugClass,
  }) {
    var warningLevelMatches = showWarningLevel[drug.warningLevel] ?? true;
    // WarningLevel.none is also shown in green in app; therefore, it should
    // also be filtered with green option
    if (drug.warningLevel == WarningLevel.none) {
      warningLevelMatches = warningLevelMatches &&
        showWarningLevel[WarningLevel.green]!;
    }
    final isDrugAccepted =
      drug.matches(query: query, useClass: useDrugClass) &&
      (activeDrugs.contains(drug.name) || showInactive) &&
      warningLevelMatches &&
      (genotypeKey.isBlank || (drug.guidelineGenotypes.contains(genotypeKey)));
    return isDrugAccepted;
  }

  List<Drug> filter(List<Drug> drugs, ActiveDrugs activeDrugs, {
    required bool useDrugClass,
  }) =>
    drugs.filter((drug) => isAccepted(
        drug,
        activeDrugs,
        useDrugClass: useDrugClass,
      )
    ).toList();
}

@freezed
class DrugListState with _$DrugListState {
  const factory DrugListState.initial() = _InitialState;
  const factory DrugListState.loading() = _LoadingState;
  const factory DrugListState.loaded(
    List<Drug> allDrugs,
    FilterState filter,
  ) = _LoadedState;
  const factory DrugListState.error() = _ErrorState;
}
