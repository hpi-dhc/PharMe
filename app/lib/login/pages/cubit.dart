import 'dart:convert' show jsonDecode;

import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../common/module.dart';
import '../models/lab.dart';

part 'cubit.freezed.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  void revertToInitialState() => emit(LoginPageState.initial());

  Future<void> loginSuccessful() async {
    MetaData.instance.isLoggedIn = true;
    await MetaData.save();
    emit(LoginPageState.loadedUserData());
  }

  // wait for externally opened app to share data
  Future<void> waitForShareReceive(BuildContext context) async {
    // to be implemented; probably with stream;
    // might be initialized on class level (to close later);
    // calls receivedShare on receive
    await receivedShare(context);
  }

  // write data as in fetchAndSaveDiplotypes
  Future<void> receivedShare(BuildContext context) async {
    // to be implemented
    // saveDiplotypes(data);
    // await loginSuccessful();
    // probably close stream (if using stream)
    throw Exception();
  }

  Future<void> loadUserData(
    BuildContext context, dynamic lab) async {
    emit(LoginPageState.loadingUserData());

    if (!shouldFetchDiplotypes()) {
      await loginSuccessful();
      return;
    }

    if (lab is KeycloakLab) {
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
        emit(LoginPageState.error(
          // ignore: use_build_context_synchronously
          context.l10n.err_could_not_retrieve_access_token,
        ));
        return;
      }

      try {
        // get data
        final url = lab.starAllelesUrl.toString();
        final response = await getDiplotypes(token, url);
        if (response.statusCode == 200) {
          await saveDiplotypes(response.body);
        } else {
          throw Exception();
        }
        await loginSuccessful();
      } catch (e) {
        // ignore: use_build_context_synchronously
        emit(LoginPageState.error(context.l10n.err_fetch_user_data_failed));
        return;
      } 
    } else if (lab is AppShareLab) {
      bool success;
      try {
        // Could use external_app_launcher, if not compatible across platfroms
        success = await launchUrl(
          Uri.parse(lab.appLink), mode: LaunchMode.externalApplication);
        // ignore: use_build_context_synchronously
        if (success) {
          // ignore: use_build_context_synchronously
          await waitForShareReceive(context);
        }
      } catch (e) {
        success = false;
      }
      if (!success) {
        emit(LoginPageState.error(
        // ignore: use_build_context_synchronously
          context.l10n.err_no_data_from_app(lab.name)));
        return;
      }
    } else {
      emit(LoginPageState.error(context.l10n.err_generic));
      return;
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
