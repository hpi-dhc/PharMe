import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/models/medication/cached_medications.dart';
import '../../common/module.dart';
import '../models/cached_reports.dart';
import '../models/warning_level.dart';

part 'cubit.freezed.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(ReportsState.initial()) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    final requestUri = annotationServerUrl.replace(
      path: 'api/v1/medications/report',
    );

    final isOnline = await hasConnectionTo(requestUri.authority);
    if (!isOnline) {
      emit(
        ReportsState.loaded(
          _filterMedications(CachedMedications.instance.medications ?? []),
        ),
      );
      return;
    }
    emit(ReportsState.loading());
    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      emit(ReportsState.error());
      return;
    }
    final medications = medicationsWithGuidelinesFromHTTPResponse(response);
    final filteredMedications = _filterMedications(medications);
    CachedMedications.instance.medications =
        CachedMedications.instance.medications.addUnique(filteredMedications);
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
        .toList();
  }
}

@freezed
class ReportsState with _$ReportsState {
  const factory ReportsState.initial() = _InitialState;
  const factory ReportsState.loading() = _LoadingState;
  const factory ReportsState.loaded(
    List<MedicationWithGuidelines> medications,
  ) = _LoadedState;
  const factory ReportsState.error() = _ErrorState;
}
