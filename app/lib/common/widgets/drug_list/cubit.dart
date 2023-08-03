import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/drug/cached_drugs.dart';
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
    required this.gene,
  });

  FilterState.initial()
      : this(
          query: '',
          showInactive: true,
          showWarningLevel: {
            for (var level in WarningLevel.values) level: true
          },
          gene: '',
        );

  FilterState.from(
    FilterState other, {
    String? query,
    bool? showInactive,
    Map<WarningLevel, bool>? showWarningLevel,
    String? gene,
  }) : this(
          query: query ?? other.query,
          showInactive: showInactive ?? other.showInactive,
          showWarningLevel: {
            for (var level in WarningLevel.values)
              level: showWarningLevel?[level] ?? other.showWarningLevel[level]!
          },
          gene: gene ?? other.gene,
        );

  FilterState.forGene(String gene)
      : this(
          query: '',
          showInactive: true,
          showWarningLevel: {
            for (var level in WarningLevel.values) level: true
          },
          gene: gene,
        );

  final String query;
  final bool showInactive;
  final Map<WarningLevel, bool> showWarningLevel;
  final String gene;

  bool isAccepted(Drug drug) {
    final userGuideline = drug.userGuideline();
    final guidelineGenes = drug.guidelines.isNotEmpty ?
      drug.guidelines.first.lookupkey.keys.toList() :
      [];
    final warningLevel =
        userGuideline?.annotations.warningLevel ?? WarningLevel.none;
    final isDrugAccepted = drug.matches(query: query) &&
        (drug.isActive() || showInactive) &&
        (showWarningLevel[warningLevel] ?? true) &&
        (gene.isBlank || (guidelineGenes.contains(gene)));
    return isDrugAccepted;
  }

  List<Drug> filter(List<Drug> drugs) => drugs.filter(isAccepted).toList();
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
