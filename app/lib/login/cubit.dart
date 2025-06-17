import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/module.dart';
import 'models/lab.dart';

part 'cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.activeDrugs) : super(LoginState.initial());

  ActiveDrugs activeDrugs;

  void revertToInitialState() => emit(LoginState.initial());

  // signInAndLoadUserData authenticates a user with a Lab and fetches their
  // genomic data from it's endpoint.
  Future<void> signInAndLoadUserData(BuildContext context, Lab lab) async {
    emit(LoginState.loadingUserData(null));
    try {
      //await lab.authenticate();
    } on LabAuthenticationCanceled {
      revertToInitialState();
      return;
    } on LabAuthenticationError {
      emit(LoginState.error(
        // ignore: use_build_context_synchronously
        context.l10n.err_could_not_retrieve_access_token,
      ));
      return;
    }

    try {
      final loadingMessage = shouldFetchDiplotypes()
          // ignore: use_build_context_synchronously
          ? context.l10n.auth_loading_data
          // ignore: use_build_context_synchronously
          : context.l10n.auth_updating_data;
      emit(LoginState.loadingUserData(loadingMessage));
      if (shouldFetchDiplotypes()) {
        final (labData, activeDrugList) = await lab.loadData();
        await saveDiplotypesAndActiveDrugs(
          labData,
          activeDrugList,
          activeDrugs,
        );
      }
      await maybeUpdateGenotypeResults();
      await maybeUpdateDrugsWithGuidelines();
      MetaData.instance.isLoggedIn = true;
      await MetaData.save();
      emit(LoginState.loadedUserData());
    } catch (e) {
      // ignore: use_build_context_synchronously
      emit(LoginState.error(context.l10n.err_fetch_user_data_failed));
    }
  }
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _InitialState;
  const factory LoginState.loadingUserData(String? loadingMessage) =
      _LoadingUserDataState;
  const factory LoginState.loadedUserData() = _LoadedUserDataState;
  const factory LoginState.error(String string) = _ErrorState;
}
