import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/models/medication/cached_medications.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial());

  Timer? searchTimeout;
  final duration = Duration(milliseconds: 500);

  void loadMedications(String value) {
    if (value.isEmpty) {
      emit(
        SearchState.loaded([]),
      );
      if (searchTimeout != null) {
        searchTimeout!.cancel();
      }
      return;
    }
    if (searchTimeout != null) {
      searchTimeout!.cancel();
    }
    searchTimeout = Timer(
      duration,
      () async {
        final requestUri = annotationServerUrl('medications').replace(
          queryParameters: {'search': value},
        );
        emit(SearchState.loading());

        final isOnline = await hasConnectionTo(requestUri.host);
        if (!isOnline) {
          _findInCachedMedications(value);
          return;
        }

        final response = await http.get(requestUri);
        if (response.statusCode != 200) {
          emit(SearchState.error());
          return;
        }
        final medications = medicationsFromHTTPResponse(response);

        emit(SearchState.loaded(medications));
      },
    );
  }

  void _findInCachedMedications(String value) {
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

    emit(SearchState.loaded(foundMeds));
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

  void setState(SearchState state) => emit(state);
}

extension _Ilike on String {
  bool ilike(String matcher) {
    return toLowerCase().contains(matcher.toLowerCase());
  }
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _InitialState;
  const factory SearchState.loading() = _LoadingState;
  const factory SearchState.loaded(List<Medication> medications) = _LoadedState;
  const factory SearchState.error() = _ErrorState;
}
