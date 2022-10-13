import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:scio/scio.dart';

import '../../models/medication/cached_medications.dart';
import '../../module.dart';

part 'cubit.freezed.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  MedicationsCubit(this._id) : super(MedicationsState.initial()) {
    loadMedications();
  }

  final int _id;

  Future<void> loadMedications() async {
    emit(MedicationsState.loading());
    final isOnline = await hasConnectionTo(annotationServerUrl().host);
    if (!isOnline) {
      final medication = _findCachedMedication(_id);
      if (medication == null) {
        emit(MedicationsState.error());
      } else {
        emit(MedicationsState.loaded(medication,
            isStarred: medication.isStarred()));
      }
      return;
    }
    final response = await sendRequest();
    if (response == null) {
      emit(MedicationsState.error());
      return;
    }
    final medication = medicationWithGuidelinesFromHTTPResponse(response);
    await CachedMedications.cache(medication);
    _initializeComprehensionContext(medication);
    final filteredMedication = medication.filterUserGuidelines();
    emit(MedicationsState.loaded(filteredMedication,
        isStarred: medication.isStarred()));
  }

  Future<void> toggleStarred() async {
    final medication = state.whenOrNull(loaded: (medication, _) => medication);
    if (medication == null) return;

    final stars = UserData.instance.starredMediationIds ?? [];
    if (medication.isStarred()) {
      UserData.instance.starredMediationIds =
          stars.filter((element) => element != _id).toList();
    } else {
      UserData.instance.starredMediationIds = stars + [_id];
    }
    await UserData.save();
    emit(
        MedicationsState.loaded(medication, isStarred: medication.isStarred()));
  }

  void _initializeComprehensionContext(MedicationWithGuidelines medication) {
    if (medication.guidelines.isEmpty) return;

    final questionContext = ComprehensionHelper.instance.questionContext;

    switch (medication.guidelines[0].warningLevel) {
      case 'danger':
        questionContext['danger_level'] = [12];
        break;
      case 'warning':
        questionContext['danger_level'] = [11];
        break;
      case 'ok':
        questionContext['danger_level'] = [10];
        break;
    }
    switch (medication.guidelines[0].phenotype.geneResult.name) {
      case 'Ultrarapid Metabolizer':
        questionContext['metabolization_class'] = [32];
        break;
      case 'Rapid Metabolizer':
        questionContext['metabolization_class'] = [15];
        break;
      case 'Normal Metabolizer':
        questionContext['metabolization_class'] = [16];
        break;
      case 'Intermediate Metabolizer':
        questionContext['metabolization_class'] = [17];
        break;
      case 'Poor Metabolizer':
        questionContext['metabolization_class'] = [18];
        break;
    }
  }

  MedicationWithGuidelines? _findCachedMedication(int id) {
    final cachedMedications = CachedMedications.instance.medications ?? [];
    final foundMedication =
        cachedMedications.firstWhereOrNull((element) => element.id == id);
    return foundMedication;
  }

  Future<Response?> sendRequest() async {
    final requestIdsUri = annotationServerUrl('medications')
        .replace(queryParameters: {'onlyIds': 'true'});
    final idsResponse = await get(requestIdsUri);
    if (idsResponse.statusCode != 200) {
      emit(MedicationsState.error());
      return null;
    }
    final randomIds = idsFromHTTPResponse(idsResponse).sample(2);
    randomIds.add(_id);
    randomIds.shuffle();
    Response? response;
    for (final id in randomIds) {
      final requestMedicationUri = annotationServerUrl('medications/$id')
          .replace(queryParameters: {'getGuidelines': 'true'});

      final tempResponse = await get(requestMedicationUri);
      if (tempResponse.statusCode != 200) {
        emit(MedicationsState.error());
        return null;
      }
      if (id == _id) response = tempResponse;
    }
    return response;
  }
}

@freezed
class MedicationsState with _$MedicationsState {
  const factory MedicationsState.initial() = _InitialState;
  const factory MedicationsState.loading() = _LoadingState;
  const factory MedicationsState.loaded(MedicationWithGuidelines medication,
      {required bool isStarred}) = _LoadedState;
  const factory MedicationsState.error() = _ErrorState;
}
