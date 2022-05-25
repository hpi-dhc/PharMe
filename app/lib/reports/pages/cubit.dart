import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/module.dart';
import '../models/cached_reports.dart';

part 'cubit.freezed.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(ReportsState.initial()) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    final requestUri = annotationServerUrl.replace(
      path: 'api/v1/medications/report',
    );
    emit(ReportsState.loading());

    // TODO(kolioOtSofia): change when kubernetes is deployed
    final isOnline = await hasConnectionTo('google.com');
    if (!isOnline) {
      emit(ReportsState.loaded(CachedReports.instance.medications ?? []));
      return;
    }

    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      emit(ReportsState.error());
      return;
    }
    final medications = medicationsWithGuidelinesFromHTTPResponse(response);
    await cacheMedications(medications);
    emit(ReportsState.loaded(medications));
  }

  Future<void> cacheMedications(
    List<MedicationWithGuidelines> medications,
  ) async {
    CachedReports.instance.lastFetch = DateTime.now();
    CachedReports.instance.medications = medications;
    await CachedReports.save();
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
