import 'package:auto_route/auto_route.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/module.dart';
import '../../../common/routing/router.dart';
import '../../../common/widgets/radiant_gradiant_mask.dart';
import '../models/lab.dart';
import 'cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String dropdownValue = 'Illumina Solutions Center Berlin';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginPageCubit(),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
        builder: (context, state) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset('assets/images/pharme_logo_horizontal.svg'),
                  Column(
                    children: state.when(
                      initial: () => _buildInitialScreen(context),
                      loadingAlleles: () => _buildLoadingScreen(context),
                      loadedAlleles: () => _buildLoadedScreen(context),
                      error: (message) => _buildErrorScreen(context, message),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildInitialScreen(BuildContext context) {
    return [
      DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Text('Please select your lab'),
          value: dropdownValue,
          onChanged: (value) {
            setState(() {
              dropdownValue = value.toString();
            });
          },
          items: labs
              .map((lab) => DropdownMenuItem(
                    value: lab.name,
                    child: Text(lab.name),
                  ))
              .toList(),
          buttonPadding: const EdgeInsets.only(left: 16, right: 16),
          buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black26),
          ),
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final found = labs.firstWhere((el) => el.name == dropdownValue);
            await context
                .read<LoginPageCubit>()
                .signInAndLoadAlleles(found.authUrl, found.allelesUrl);
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          child: Text(context.l10n.auth_sign_in),
        ),
      )
    ];
  }

  List<Widget> _buildLoadingScreen(BuildContext context) {
    return [
      SizedBox(
        width: 200,
        height: 200,
        child: RadiantGradientMask(
          colors: [
            context.theme.colorScheme.primaryVariant,
            context.theme.colorScheme.secondaryVariant,
          ],
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildLoadedScreen(BuildContext context) {
    return [
      RadiantGradientMask(
        colors: [
          context.theme.colorScheme.primaryVariant,
          context.theme.colorScheme.secondaryVariant,
        ],
        child: Icon(
          Icons.task_alt,
          size: 150,
          color: Colors.white,
        ),
      ),
      Text('Successfully imported data'),
      SizedBox(height: 25),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.router.replace(MainRoute()),
          child: Text('Continue'),
        ),
      ),
    ];
  }

  List<Widget> _buildErrorScreen(BuildContext context, String message) {
    return [
      RadiantGradientMask(
        colors: [
          context.theme.colorScheme.primaryVariant,
          context.theme.colorScheme.secondaryVariant,
        ],
        child: Icon(
          Icons.warning_amber_outlined,
          size: 150,
          color: Colors.white,
        ),
      ),
      Text(message),
      SizedBox(height: 25),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<LoginPageCubit>().emit(LoginPageState.initial());
          },
          child: Text('Retry'),
        ),
      ),
    ];
  }
}
