import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:http/http.dart' as http;

part 'cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial());

  Future<void> login(String username, String password) async {
    emit(ProfileState.loading('Loading genomic data...'));

    try {
      // Username: admin
      // Password: 123
      final response = await http.post(
        Uri.parse('http://vm-bp2021eb1.dhclab.i.hpi.de:8081/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      /* 
      await Future.delayed(
        const Duration(seconds: 10),
        () => {},
      );
      */

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ProfileState.loaded(response.body));
      } else {
        emit(ProfileState.error(jsonDecode(response.body)['message']));
      }
    } catch (error) {
      emit(ProfileState.error(error.hashCode.toString()));
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
