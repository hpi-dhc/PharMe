import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/widgets/headings.dart';
import 'cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<TokenResponse> authenticate() async {
    // parameters here just for the sake of the question
    final uri = Uri.parse('http://10.0.2.2:28080/auth/realms/pharme');
    const clientId = 'pharme-app';
    final scopes = List<String>.of(['openid', 'profile']);
    const port = 4200;

    final issuer = await Issuer.discover(uri);
    final client = Client(issuer, clientId);

    final authenticator = Authenticator(client, scopes: scopes, port: port,
        urlLancher: (url) async {
      if (await canLaunch(url)) {
        await launch(url, forceWebView: true);
      } else {
        throw Exception('Could not launch $url');
      }
    });

    final c = await authenticator.authorize();
    await closeWebView();

    final token = await c.getTokenResponse();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading('Login to Lab Server'),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      authenticate();
                      /* if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().login(
                            usernameController.text, passwordController.text);
                      } */
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)),
                    child: state.maybeWhen(
                      loading: (message) => SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          value: null,
                          color: Colors.white,
                        ),
                      ),
                      orElse: () => Text('Login'),
                    ),
                  ),
                  if (state is LoadingState || state is LoadedState)
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: state.maybeWhen(
                        loading: Text.new,
                        loaded: Text.new,
                        orElse: () => null,
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
