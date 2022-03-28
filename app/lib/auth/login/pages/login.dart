import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../common/module.dart';
import '../../../common/routing/router.dart';
import 'cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<Lab> labs = [
    Lab(
      'Illumina Solutions Center Berlin',
      'http://172.20.24.66:28080/auth/realms/pharme',
      '${dotenv.env['BACKEND_URL']}/api/v1/star-alleles',
    ),
    Lab(
      'Mount Sinai Hospital (NYC)',
      'http://172.20.24.66:28080/auth/realms/pharme',
      '${dotenv.env['BACKEND_URL']}/api/v1/star-alleles',
    )
  ];
  String dropdownValue = 'Illumina Solutions Center Berlin';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginPageCubit(),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
        builder: (context, state) {
          return state.when(
            initial: () => _buildSignInForm(context),
            loadingAlleles: () => _buildLoadingScreen(context),
            loadedAlleles: () => _buildLoadedAllelesScreen(context),
            error: (message) => _buildErrorScreen(context, message),
          );
        },
      ),
    );
  }

  // TODO: for refactoring purposes later
  // ignore: unused_element
  Widget _buildStatusScreen(BuildContext context, List<Widget> children) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton(
                value: dropdownValue,
                icon: Icon(Icons.keyboard_arrow_down),
                items: labs
                    .map((items) => DropdownMenuItem(
                        value: items.name, child: Text(items.name)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue.toString();
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final found =
                      labs.firstWhere((el) => el.name == dropdownValue);
                  await context
                      .read<LoginPageCubit>()
                      .signInAndLoadData(found.authUrl, found.allelesUrl);
                },
                child: Text(context.l10n.auth_sign_in),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedAllelesScreen(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 150,
              ),
              Text('Successfully imported data'),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.router.replace(MainRoute()),
                  child: Text('Continue'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 150,
              ),
              Text(message),
              ElevatedButton(
                onPressed: () {
                  context.read<LoginPageCubit>().emit(LoginPageState.initial());
                },
                child: Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Lab {
  Lab(this.name, this.authUrl, this.allelesUrl);

  String name;
  String authUrl;
  String allelesUrl;
}
