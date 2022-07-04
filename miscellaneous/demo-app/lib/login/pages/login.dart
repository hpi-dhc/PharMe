import '../../../common/module.dart';
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
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox.expand(
                  child: state.when(
                    initial: () => _buildInitialScreen(context),
                    loading: () => _buildLoadingScreen(context),
                    loaded: () => _buildLoadedScreen(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/logo-horizontal.png'),
        Column(
          children: [
            Icon(
              Icons.lock_open,
              color: Colors.green,
              size: 128,
            ),
            SizedBox(height: 16),
            Text(
              'You are already logged in',
              style: context.textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: context.read<LoginPageCubit>().fakeLoadGeneticData,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text('Load my genetic data'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          'assets/images/pharme_logo_horizontal.svg',
        ),
        CircularProgressIndicator(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null, // disabled state
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text('Load my genetic data'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          'assets/images/pharme_logo_horizontal.svg',
        ),
        Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 128,
            ),
            SizedBox(height: 16),
            Text(
              'Data loaded successfully',
              style: context.textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.router.replace(MainRoute()),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text('Continue to PharMe'),
          ),
        ),
      ],
    );
  }
}
