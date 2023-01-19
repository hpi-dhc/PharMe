import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:scio/scio.dart';

import '../../models/drug/cached_drugs.dart';
import '../../module.dart';

part 'cubit.freezed.dart';

class DrugsCubit extends Cubit<DrugsState> {
  DrugsCubit(this._id) : super(DrugsState.initial()) {
    loadDrugs();
  }

  final int _id;

  Future<void> loadDrugs() async {
    emit(DrugsState.loading());
    final isOnline = await hasConnectionTo(annotationServerUrl().host);
    if (!isOnline) {
      final drug = _findCachedDrug(_id);
      if (drug == null) {
        emit(DrugsState.error());
      } else {
        emit(DrugsState.loaded(drug, isStarred: drug.isStarred()));
      }
      return;
    }
    final response = await sendRequest();
    if (response == null) {
      emit(DrugsState.error());
      return;
    }
    final drug = drugWithGuidelinesFromHTTPResponse(response);
    await CachedDrugs.cache(drug);
    _initializeComprehensionContext(drug);
    final filteredDrug = drug.filterUserGuidelines();
    emit(DrugsState.loaded(filteredDrug, isStarred: drug.isStarred()));
  }

  Future<void> toggleStarred() async {
    final drug = state.whenOrNull(loaded: (drug, _) => drug);
    if (drug == null) return;

    final stars = UserData.instance.starredMediationIds ?? [];
    if (drug.isStarred()) {
      UserData.instance.starredMediationIds =
          stars.filter((element) => element != _id).toList();
    } else {
      UserData.instance.starredMediationIds = stars + [_id];
    }
    await UserData.save();
    emit(DrugsState.loaded(drug, isStarred: drug.isStarred()));
  }

  void _initializeComprehensionContext(Drug drug) {
    if (drug.guidelines.isEmpty) return;

    final questionContext = ComprehensionHelper.instance.questionContext;

    switch (drug.guidelines[0].warningLevel) {
      case WarningLevel.red:
        questionContext['danger_level'] = [12];
        break;
      case WarningLevel.warning:
        questionContext['danger_level'] = [11];
        break;
      case WarningLevel.green:
        questionContext['danger_level'] = [10];
        break;
      default:
        break;
    }
    switch (drug.guidelines[0].phenotype.geneResult.name) {
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

  Drug? _findCachedDrug(int id) {
    final cachedDrugs = CachedDrugs.instance.drugs ?? [];
    final foundDrug =
        cachedDrugs.firstWhereOrNull((element) => element.id == id);
    return foundDrug;
  }

  Future<Response?> sendRequest() async {
    final requestIdsUri = annotationServerUrl('drugs')
        .replace(queryParameters: {'onlyIds': 'true'});
    final idsResponse = await get(requestIdsUri);
    if (idsResponse.statusCode != 200) {
      emit(DrugsState.error());
      return null;
    }
    final randomIds = idsFromHTTPResponse(idsResponse).sample(2);
    randomIds.add(_id);
    randomIds.shuffle();
    Response? response;
    for (final id in randomIds) {
      final requestDrugUri = annotationServerUrl('drugs/$id')
          .replace(queryParameters: {'getGuidelines': 'true'});

      final tempResponse = await get(requestDrugUri);
      if (tempResponse.statusCode != 200) {
        emit(DrugsState.error());
        return null;
      }
      if (id == _id) response = tempResponse;
    }
    return response;
  }
}

@freezed
class DrugsState with _$DrugsState {
  const factory DrugsState.initial() = _InitialState;
  const factory DrugsState.loading() = _LoadingState;
  const factory DrugsState.loaded(Drug drug,
      {required bool isStarred}) = _LoadedState;
  const factory DrugsState.error() = _ErrorState;
}
