import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/constants.dart';
import '../../common/module.dart';

part 'cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial());

  Future<void> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    emit(ProfileState.loading(context.l10n.profile_page_loading));

    try {
      final response = await http.post(
        Uri.parse('$labServerUrl/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ProfileState.loaded(response.body));
      } else {
        emit(ProfileState.error(jsonDecode(response.body)['message']));
      }
    } catch (error) {
      emit(ProfileState.error(error.toString()));
    }
  }
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _InitialState;
  const factory ProfileState.loading(String message) = LoadingState;
  const factory ProfileState.loaded(String message) = LoadedState;
  const factory ProfileState.error(String error) = _ErrorState;
}
