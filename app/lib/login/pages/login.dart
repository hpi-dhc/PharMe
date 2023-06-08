import 'package:dropdown_button2/dropdown_button2.dart';

import '../../../common/module.dart';
import '../../common/widgets/share_receive.dart';
import '../models/lab.dart';
import 'cubit.dart';

class LoginPage extends HookWidget {
  const LoginPage({
    Key? key,
    @visibleForTesting this.cubit,
  }) : super(key: key);

  final LoginPageCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState(labs.first.name);

    return BlocProvider(
      create: (context) => cubit ?? LoginPageCubit(),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  ShareReceive(),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                      ),
                    ),
                  ),
                  Positioned(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: state.when(
                          initial: () =>
                              _buildInitialScreen(context, dropdownValue),
                          loadingUserData: CircularProgressIndicator.new,
                          loadedUserData: () => _buildLoadedScreen(context),
                          error: (message) =>
                              _buildErrorScreen(context, message),
                        ),
                      ),
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

  Widget _buildInitialScreen(
    BuildContext context,
    ValueNotifier<String> dropdownValue,
  ) {
    Future<void> action() async {
      final selectedLab = labs.firstWhere(
        (el) => el.name == dropdownValue.value,
      );
      await context
          .read<LoginPageCubit>()
          .loadUserData(context, selectedLab);
    }

    return _buildColumnWrapper(
      action: action,
      actionText: context.l10n.auth_sign_in,
      children: [
        Text(
          context.l10n.auth_welcome,
          style: PharMeTheme.textTheme.titleLarge,
        ),
        SizedBox(height: PharMeTheme.smallSpace),
        Text(
          context.l10n.auth_choose_lab,
          style: PharMeTheme.textTheme.titleMedium,
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            dropdownOverButton: true,
            hint: Text(context.l10n.auth_choose_lab),
            value: dropdownValue.value,
            onChanged: (value) {
              dropdownValue.value = value.toString();
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
              border: Border.all(color: PharMeTheme.borderColor),
            ),
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScreen(BuildContext context) {
    return _buildColumnWrapper(
      action: () => context.router.replace(MainRoute()),
      actionText: context.l10n.general_continue,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: PharMeTheme.primaryColor,
          size: 96,
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        Text(
          context.l10n.auth_success,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return _buildColumnWrapper(
      action: () => context.read<LoginPageCubit>().revertToInitialState(),
      actionText: context.l10n.general_retry,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: PharMeTheme.errorColor,
          size: 96,
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        Text(
          message,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildColumnWrapper({
    required void Function()? action,
    required String actionText,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...children,
        SizedBox(height: PharMeTheme.mediumSpace),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: action,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text(actionText),
          ),
        ),
      ],
    );
  }
}
