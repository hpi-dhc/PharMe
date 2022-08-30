import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

import '../../common/models/medication/cached_medications.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(ReportsState.initial()) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    final requestUri = annotationServerUrl('medications').replace(
      queryParameters: {
        'withGuidelines': 'true',
        'getGuidelines': 'true',
      },
    );

    final isOnline = await hasConnectionTo(requestUri.host);
    if (!isOnline) {
      emit(
        ReportsState.loaded(
          _filterMedications(CachedMedications.instance.medications ?? []),
        ),
      );
      return;
    }
    emit(ReportsState.loading());
    final response = await get(requestUri);
    if (response.statusCode != 200) {
      emit(ReportsState.error());
      return;
    }
    final medications = medicationsWithGuidelinesFromHTTPResponse(response);
    final filteredMedications = _filterMedications(medications);
    await CachedMedications.cacheAll(filteredMedications);
    await CachedMedications.save();
    emit(ReportsState.loaded(filteredMedications));
  }

  bool _containsOnlyOkGuidelines(List<Guideline> guidelines) {
    final warningLevels = guidelines.map((e) => e.warningLevel);
    return warningLevels.every((warningLevel) {
      return warningLevel == WarningLevel.ok.name;
    });
  }

  List<MedicationWithGuidelines> _filterMedications(
    List<MedicationWithGuidelines> medications,
  ) {
    final filteredMedications = medications.map(filterUserGuidelines).toList();
    return filteredMedications
        .where(
          (element) =>
              element.guidelines.isNotEmpty &&
              !_containsOnlyOkGuidelines(element.guidelines),
        )
        .map(_setCritical)
        .toList();
  }

  MedicationWithGuidelines _setCritical(MedicationWithGuidelines med) {
    med.isCritical = true;
    return med;
  }
}

@freezed
class ReportsState with _$ReportsState {
  const factory ReportsState.initial() = _InitialState;
  const factory ReportsState.loading() = _LoadingState;
  // add a member here that indicates showing the s4h button, load in the cubit by asking android
  // button then talks to android again
  const factory ReportsState.loaded(
    List<MedicationWithGuidelines> medications,
  ) = _LoadedState;
  const factory ReportsState.error() = _ErrorState;
}
