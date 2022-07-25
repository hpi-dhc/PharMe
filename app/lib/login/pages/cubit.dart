import 'dart:convert' show jsonDecode;

import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../../common/module.dart';
import '../models/lab.dart';

part 'cubit.freezed.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  void revertToInitialState() => emit(LoginPageState.initial());

  // signInAndLoadUserData authenticates a user with a Lab and fetches their
  // genomic data from it's endpoint.
  Future<void> signInAndLoadUserData(BuildContext context, Lab lab) async {
    emit(LoginPageState.loadingUserData());

    try {
      // authenticate
      String token;
      try {
        token = await _getAccessToken(
          context,
          authUrl: lab.authUrl,
          tokenUrl: lab.tokenUrl,
        );
      } on PlatformException catch (e) {
        if (e.code == 'CANCELED') {
          revertToInitialState();
        } else {
          emit(LoginPageState.error(context.l10n.err_generic));
        }
        return;
      }

      // get data
      await fetchAndSaveDiplotypes(token, lab.endpoint);
      await fetchAndSaveLookups();

      // login + fetching of data successful
      MetaData.instance.isLoggedIn = true;
      await MetaData.save();
      emit(LoginPageState.loadedUserData());
    } catch (e) {
      emit(LoginPageState.error(context.l10n.err_fetch_user_data_failed));
    }
  }

  Future<String> _getAccessToken(
    BuildContext context, {
    required Uri authUrl,
    required Uri tokenUrl,
  }) async {
    const clientId = 'pharme-app';
    const callbackUrlScheme = 'localhost';

    // Construct the url
    final url = authUrl.replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'scope': 'openid profile',
    });

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
      url: url.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];

    // Use this code to get an access token
    final response = await http.post(tokenUrl, body: {
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'grant_type': 'authorization_code',
      'code': code,
    });

    // Get the access token from the response
    return jsonDecode(response.body)['access_token'] as String;
  }
}

@freezed
class LoginPageState with _$LoginPageState {
  const factory LoginPageState.initial() = _InitialState;
  const factory LoginPageState.loadingUserData() = _LoadingUserDataState;
  const factory LoginPageState.loadedUserData() = _LoadedUserDataState;
  const factory LoginPageState.error(String string) = _ErrorState;
}
