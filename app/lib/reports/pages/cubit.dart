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
        ReportsState.loaded(CachedMedications.instance.medications != null
            ? CachedMedications.instance.medications!.filterCritical()
            : []),
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
    final filteredMedications = medications.filterCritical();
    await CachedMedications.cacheAll(filteredMedications);
    await CachedMedications.save();
    emit(ReportsState.loaded(filteredMedications));
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
