import 'dart:convert' show jsonDecode;

import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../common/module.dart';
import 'models/lab.dart';

part 'cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.activeDrugs): super(LoginState.initial());

  ActiveDrugs activeDrugs;

  void revertToInitialState() => emit(LoginState.initial());

  // signInAndLoadUserData authenticates a user with a Lab and fetches their
  // genomic data from it's endpoint.
  Future<void> signInAndLoadUserData(BuildContext context, Lab lab) async {
    emit(LoginState.loadingUserData());

    // authenticate
    String? token;
    try {
      token = await _getAccessToken(
        context,
        authUrl: lab.authUrl,
        tokenUrl: lab.tokenUrl,
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        revertToInitialState();
        return;
      }
    }

    if (token == null) {
      emit(LoginState.error(
        // ignore: use_build_context_synchronously
        context.l10n.err_could_not_retrieve_access_token,
      ));
      return;
    }

    try {
      // get data
      await fetchAndSaveDiplotypesAndActiveDrugs(
        token, lab.starAllelesUrl.toString(), activeDrugs);
      await updateGenotypeResults();

      await updateCachedDrugs();

      // login + fetching of data successful
      MetaData.instance.isLoggedIn = true;
      await MetaData.save();
      emit(LoginState.loadedUserData());
    } catch (e) {
      // ignore: use_build_context_synchronously
      emit(LoginState.error(context.l10n.err_fetch_user_data_failed));
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
class LoginState with _$LoginState {
  const factory LoginState.initial() = _InitialState;
  const factory LoginState.loadingUserData() = _LoadingUserDataState;
  const factory LoginState.loadedUserData() = _LoadedUserDataState;
  const factory LoginState.error(String string) = _ErrorState;
}
