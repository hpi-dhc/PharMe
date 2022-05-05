import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/module.dart' hide MetaData;
import '../../../common/utilities/genome_data.dart';
import '../../common/models/metadata.dart';
import '../models/lab.dart';

part 'cubit.freezed.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  void revertToInitialState() => emit(LoginPageState.initial());

  // signInAndLoadUserData authenticates a user with a Lab and fetches their
  // genomic data from it's endpoint.
  Future<void> signInAndLoadUserData(BuildContext context, Lab lab) async {
    try {
      // authenticate
      final token = await _getAccessToken(lab.authUrl);
      emit(LoginPageState.loadingUserData());

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
  const factory LoginPageState.loadingUserData() = _LoadingUserDataState;
  const factory LoginPageState.loadedUserData() = _LoadedUserDataState;
  const factory LoginPageState.error(String string) = _ErrorState;
}
