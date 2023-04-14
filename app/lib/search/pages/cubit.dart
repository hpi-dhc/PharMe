import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/models/drug/cached_drugs.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    FilterState? initialFilter,
  }) : super(SearchState.initial()) {
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
        SearchState.loaded(
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
        emit(SearchState.loaded(drugs, filter));
        return;
      }
      if (!updateIfNull) {
        emit(SearchState.error());
        return;
      }
    }

    emit(SearchState.loading());
    try {
      await updateCachedDrugs();
      await loadDrugs(updateIfNull: false, filter: filter);
    } catch (error) {
      emit(SearchState.error());
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

  final String query;
  final bool showInactive;
  final Map<WarningLevel, bool> showWarningLevel;
  final String gene;

  bool isAccepted(Drug drug) {
    final guideline = drug.userGuideline();
    final warningLevel =
        guideline?.annotations.warningLevel ?? WarningLevel.none;
    return drug.matches(query: query) &&
        (drug.isActive() || showInactive) &&
        (showWarningLevel[warningLevel] ?? true) &&
        (gene.isBlank || (guideline?.lookupkey.keys.contains(gene) ?? false));
  }

  List<Drug> filter(List<Drug> drugs) => drugs.filter(isAccepted).toList();
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _InitialState;
  const factory SearchState.loading() = _LoadingState;
  const factory SearchState.loaded(
    List<Drug> allDrugs,
    FilterState filter,
  ) = _LoadedState;
  const factory SearchState.error() = _ErrorState;
}
