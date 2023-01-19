import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/models/drug/cached_drugs.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial(filterStarred: true)) {
    loadDrugs(searchValue);
  }

  Timer? searchTimeout;
  String searchValue = '';
  final duration = Duration(milliseconds: 500);

  void loadDrugs(String value, {bool? filterStarred}) {
    final filter = filterStarred ?? isFiltered();
    searchValue = value;
    if (searchTimeout != null) searchTimeout!.cancel();
    searchTimeout = Timer(
      duration,
      () async {
        emit(SearchState.loading(filterStarred: filter));
        var drugs = await _findDrugs(value);
        if (drugs == null) {
          emit(SearchState.error(filterStarred: filter));
          return;
        }
        if (filter) {
          drugs = drugs.filter((drug) => drug.isStarred()).toList();
          await CachedDrugs.cacheAll(drugs);
          await CachedDrugs.save();
        }
        emit(SearchState.loaded(drugs, filterStarred: filter));
      },
    );
  }

  void toggleFilter() {
    loadDrugs(searchValue, filterStarred: !isFiltered());
  }

  bool isFiltered() {
    return state.when(
        initial: (filterStarred) => filterStarred,
        loading: (filterStarred) => filterStarred,
        loaded: (_, filterStarred) => filterStarred,
        error: (filterStarred) => filterStarred);
  }

  Future<List<Drug>?> _findDrugs(String value) async {
    final requestUri = annotationServerUrl('drugs').replace(
      queryParameters: {
        'getGuidelines': 'true',
        'withGuidelines': 'true',
        'search': value
      },
    );
    final isOnline = await hasConnectionTo(requestUri.host);
    if (!isOnline) {
      return _findInCachedDrugs(value);
    }

    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      return null;
    }
    return drugsWithGuidelinesFromHTTPResponse(response);
  }

  List<Drug> _findInCachedDrugs(String value) {
    CachedDrugs.instance.drugs ??= [];
    final foundMeds = CachedDrugs.instance.drugs!
        .where((med) => med.matches(query: value))
        .toList();
    return foundMeds;
  }
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial({required bool filterStarred}) =
      _InitialState;
  const factory SearchState.loading({required bool filterStarred}) =
      _LoadingState;
  const factory SearchState.loaded(List<Drug> drugs,
      {required bool filterStarred}) = _LoadedState;
  const factory SearchState.error({required bool filterStarred}) = _ErrorState;
}
