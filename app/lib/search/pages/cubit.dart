import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/models/drug/cached_drugs.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial()) {
    loadDrugs();
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

  Future<void> loadDrugs({bool updateIfNull = true}) async {
    final drugs = CachedDrugs.instance.drugs;
    if (drugs != null) {
      emit(SearchState.loaded(drugs, FilterState.initial()));
      return;
    }
    if (!updateIfNull) {
      emit(SearchState.error());
      return;
    }

    emit(SearchState.loading());
    try {
      await updateCachedDrugs();
      await loadDrugs(updateIfNull: false);
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
  });

  FilterState.initial()
      : this(query: '', showInactive: true, showWarningLevel: {
          for (var level in WarningLevel.values) level: true
        });

  FilterState.from(
    FilterState other, {
    String? query,
    bool? showInactive,
    Map<WarningLevel, bool>? showWarningLevel,
  }) : this(
          query: query ?? other.query,
          showInactive: showInactive ?? other.showInactive,
          showWarningLevel: {
            for (var level in WarningLevel.values)
              level: showWarningLevel?[level] ?? other.showWarningLevel[level]!
          },
        );

  final String query;
  final bool showInactive;
  final Map<WarningLevel, bool> showWarningLevel;

  bool isAccepted(Drug drug) {
    final warningLevel = drug.userGuideline()?.annotations.warningLevel;
    return drug.matches(query: query) &&
        (drug.isActive() || showInactive) &&
        (showWarningLevel[warningLevel] ?? true);
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
