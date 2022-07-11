import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/module.dart';
import '../../common/utilities/genome_data.dart';

part 'cubit.freezed.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  Future<void> fakeLoadGeneticData() async {
    emit(LoginPageState.loading());

    // get data
    await fetchAndSaveDiplotypes();
    await fetchAndSaveLookups();

    MetaData.instance.isLoggedIn = true;
    await MetaData.save();
    await Future.delayed(Duration(seconds: 3));

    emit(LoginPageState.loaded());
  }
}

@freezed
class LoginPageState with _$LoginPageState {
  const factory LoginPageState.initial() = _InitialState;
  const factory LoginPageState.loading() = _LoadingState;
  const factory LoginPageState.loaded() = _LoadedState;
}
