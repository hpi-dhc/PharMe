import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/services.dart';
import '../../../common/utilities/genome_data.dart';

part 'cubit.freezed.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  void revertToInitialState() => emit(LoginPageState.initial());

  Future<void> signInAndLoadAlleles(String authUrl, String allelesUrl) async {
    try {
      final token = await _getAccessToken(authUrl);
      emit(LoginPageState.loadingAlleles());
      await fetchAndSaveAllesData(token, allelesUrl);
      await fetchAndSaveLookups();
      // Login Successful
      await getBox(Boxes.preferences).put('isLoggedIn', true);
      emit(LoginPageState.loadedAlleles());
    } catch (e) {
      emit(LoginPageState.error(e.toString()));
    }
  }

  Future<String> _getAccessToken(String authUrl) async {
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
}

@freezed
class LoginPageState with _$LoginPageState {
  const factory LoginPageState.initial() = _InitialState;
  const factory LoginPageState.loadingAlleles() = _LoadingAllelesState;
  const factory LoginPageState.loadedAlleles() = _LoadedAllelesState;
  const factory LoginPageState.error(String string) = _ErrorState;
}
