import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/widgets/headings.dart';
import '../../common/module.dart';
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
                  Heading(context.l10n.profile_page_header),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.profile_page_username,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.profile_page_enter_username;
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
                      labelText: context.l10n.profile_page_password,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.profile_page_enter_password;
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().login(
                              context,
                              usernameController.text,
                              passwordController.text,
                            );
                      }
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
                      orElse: () => Text(context.l10n.profile_page_sign_in),
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
