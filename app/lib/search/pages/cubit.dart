import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/models/medication/cached_medications.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial(filterStarred: true)) {
    loadMedications(searchValue);
  }

  Timer? searchTimeout;
  String searchValue = '';
  final duration = Duration(milliseconds: 500);

  void loadMedications(String value, {bool? filterStarred}) {
    final filter = filterStarred ?? isFiltered();
    searchValue = value;
    if (value.isEmpty) {
      emit(
        SearchState.loaded([], filterStarred: filter),
      );
      if (searchTimeout != null) searchTimeout!.cancel();
      return;
    }
    if (searchTimeout != null) searchTimeout!.cancel();
    searchTimeout = Timer(
      duration,
      () async {
        emit(SearchState.loading(filterStarred: filter));
        var medications = await _findMedications(value);
        if (medications == null) {
          emit(SearchState.error(filterStarred: filter));
          return;
        }
        if (filter) {
          medications = medications
              .filter((medication) => medication.isStarred())
              .toList();
        }
        emit(SearchState.loaded(medications, filterStarred: filter));
      },
    );
  }

  void toggleFilter() {
    loadMedications(searchValue, filterStarred: !isFiltered());
  }

  bool isFiltered() {
    return state.when(
        initial: (filterStarred) => filterStarred,
        loading: (filterStarred) => filterStarred,
        loaded: (_, filterStarred) => filterStarred,
        error: (filterStarred) => filterStarred);
  }

  Future<List<Medication>?> _findMedications(String value) async {
    final requestUri = annotationServerUrl('medications').replace(
      queryParameters: {'search': value},
    );
    final isOnline = await hasConnectionTo(requestUri.host);
    if (!isOnline) {
      return _findInCachedMedications(value);
    }

    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      return null;
    }
    return medicationsFromHTTPResponse(response);
  }

  List<Medication> _findInCachedMedications(String value) {
    CachedMedications.instance.medications ??= [];
    final foundMeds = CachedMedications.instance.medications!
        .where(
      (med) =>
          med.name.ilike(value) ||
          _medDescriptionMatches(value, med) ||
          _medSynonymsMatch(value, med) ||
          _medDrugclassMatches(value, med),
    )
        .map(
      (e) {
        return Medication(
          e.id,
          e.name,
          e.description!,
          e.drugclass,
          e.indication,
        );
      },
    ).toList();

    return foundMeds;
  }

  bool _medDescriptionMatches(String value, MedicationWithGuidelines med) {
    if (med.description.isNotNullOrBlank) {
      return med.description!.ilike(value);
    }
    return false;
  }

  bool _medSynonymsMatch(String value, MedicationWithGuidelines med) {
    if (med.synonyms != null) {
      return med.synonyms!.any((element) => element.ilike(value));
    }
    return false;
  }

  bool _medDrugclassMatches(String value, MedicationWithGuidelines med) {
    if (med.drugclass.isNotNullOrBlank) {
      return med.drugclass!.ilike(value);
    }
    return false;
  }
}

extension _Ilike on String {
  bool ilike(String matcher) {
    return toLowerCase().contains(matcher.toLowerCase());
  }
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial({required bool filterStarred}) =
      _InitialState;
  const factory SearchState.loading({required bool filterStarred}) =
      _LoadingState;
  const factory SearchState.loaded(List<Medication> medications,
      {required bool filterStarred}) = _LoadedState;
  const factory SearchState.error({required bool filterStarred}) = _ErrorState;
}
