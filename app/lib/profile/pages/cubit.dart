import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial());

  Future<void> login(String username, String password) async {
    emit(ProfileState.loading());

    try {
      await Future.delayed(
        const Duration(seconds: 10),
        () => {},
      );

      emit(ProfileState.loaded());
    } catch (error) {
      emit(ProfileState.error());
    }
  }
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _InitialState;
  const factory ProfileState.loading() = _LoadingState;
  const factory ProfileState.loaded() = _LoadedState;
  const factory ProfileState.error() = _ErrorState;
}
