import 'package:dropdown_button2/dropdown_button2.dart';

import '../../../common/module.dart';
import '../models/lab.dart';
import 'cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
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
                      loadingUserData: () => _buildLoadingScreen(context),
                      loadedUserData: () => _buildLoadedScreen(context),
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
          hint: Text(context.l10n.auth_choose_lab),
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
                .signInAndLoadUserData(context, found);
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
            PharMeTheme.primaryContainer,
            PharMeTheme.secondaryContainer,
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
          PharMeTheme.primaryContainer,
          PharMeTheme.secondaryContainer,
        ],
        child: Icon(
          Icons.task_alt,
          size: 152,
          color: Colors.white,
        ),
      ),
      Text(context.l10n.auth_success),
      SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.router.replace(MainRoute()),
          child: Text(context.l10n.general_continue),
        ),
      ),
    ];
  }

  List<Widget> _buildErrorScreen(BuildContext context, String message) {
    return [
      RadiantGradientMask(
        colors: [
          PharMeTheme.primaryContainer,
          PharMeTheme.secondaryContainer,
        ],
        child: Icon(
          Icons.warning_amber_outlined,
          size: 152,
          color: Colors.white,
        ),
      ),
      Text(message),
      SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () =>
              context.read<LoginPageCubit>().revertToInitialState(),
          child: Text(context.l10n.general_retry),
        ),
      ),
    ];
  }
}
