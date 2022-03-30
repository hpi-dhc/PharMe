import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' hide Client;
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../profile/models/hive/alleles.dart';

part 'cubit.freezed.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  Future<void> signInAndLoadAlleles(String authUrl, String allelesUrl) async {
    try {
      final token = await _getAccessToken(authUrl);
      emit(LoginPageState.loadingAlleles());
      await _fetchAndSaveAllesData(token, allelesUrl);
      // Login Successful
      await Hive.box('preferences').put('isLoggedIn', true);
      emit(LoginPageState.loadedAlleles());
    } catch (e) {
      emit(LoginPageState.error(e.toString()));
    }
  }

  Future<String> _getAccessToken(String authUrl) async {
    // 'http://172.20.24.66:28080/auth/realms/pharme'
    final uri = Uri.parse(authUrl);
    const clientId = 'pharme-app';
    final scopes = List<String>.of(['openid', 'profile']);
    const port = 4200;

    final issuer = await Issuer.discover(uri);
    final client = Client(issuer, clientId);

    final authenticator = Authenticator(
      client,
      scopes: scopes,
      port: port,
      urlLancher: (url) async {
        if (await canLaunch(url)) {
          await launch(url, forceWebView: true);
        } else {
          throw Exception('Could not launch $url');
        }
      },
    );
    final credentials = await authenticator.authorize();
    await closeWebView();
    return credentials.getTokenResponse().then((res) => res.accessToken ?? '');
  }

  Future<void> _fetchAndSaveAllesData(String token, String url) async {
    final userData = Hive.box<Alleles>('userData');
    if (userData.get('alleles') == null) {
      final response = await _getStarAlleles(token, url);
      if (response.statusCode == 200) {
        await _saveAlleleData(response, 'userData');
      } else {
        throw Exception('Error occurred during loading of allele data');
      }
    }
  }

  Future<Response> _getStarAlleles(String? token, String url) async =>
      get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

  Future<void> _saveAlleleData(Response response, String boxname) async {
    final json = jsonDecode(response.body);
    final alleles = Alleles.fromJson(json);
    return Hive.box<Alleles>('userData').put('alleles', alleles);
  }
}

@freezed
class LoginPageState with _$LoginPageState {
  const factory LoginPageState.initial() = _InitialState;
  const factory LoginPageState.loadingAlleles() = _LoadingAllelesState;
  const factory LoginPageState.loadedAlleles() = _LoadedAllelesState;
  const factory LoginPageState.error(String string) = _ErrorState;
}
