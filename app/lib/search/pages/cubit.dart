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
  bool filterStarred = true;
  final duration = Duration(milliseconds: 500);

  void search({String? query, bool? filterStarred}) {
    this.filterStarred = filterStarred ?? this.filterStarred;
    searchValue = query ?? searchValue;

    state.whenOrNull(
        initial: loadDrugs,
        loaded: (allDrugs, _) => emit(SearchState.loaded(
            allDrugs,
            allDrugs
                .filter((drug) =>
                    (!this.filterStarred || drug.isStarred()) &&
                    drug.matches(query: searchValue))
                .toList())),
        error: loadDrugs);
  }

  Future<void> loadDrugs({bool updateIfNull = true}) async {
    final drugs = CachedDrugs.instance.drugs;
    if (drugs != null) {
      _emitFilteredLoaded(drugs);
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

  void toggleFilter() {
    search(filterStarred: !filterStarred);
  }

  void _emitFilteredLoaded(List<Drug> drugs) {
    emit(SearchState.loaded(
        drugs,
        drugs
            .filter((drug) =>
                (!filterStarred || drug.isStarred()) &&
                drug.matches(query: searchValue))
            .toList()));
  }
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _InitialState;
  const factory SearchState.loading() = _LoadingState;
  const factory SearchState.loaded(
      List<Drug> allDrugs, List<Drug> filteredDrugs) = _LoadedState;
  const factory SearchState.error() = _ErrorState;
}
