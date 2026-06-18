import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/features/auth/login/bloc/login_bloc.dart';
import 'package:flutter_example/features/auth/login/view/widgets/login_input_text_fields.dart';
import 'package:flutter_example/features/auth/login/view/widgets/login_sign_up.dart';
import 'package:flutter_example/features/auth/login/view/widgets/login_title.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:bm_flutter/core.dart';

@RoutePage()
class LoginView extends StatefulWidget implements AutoRouteWrapper {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>()..add(LoginEvent.started()),
      child: this,
    );
  }
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _userNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              previous.username != current.username,
          listener: (context, state) {
            _usernameController.text = state.username;
          },
        ),
        BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              previous.password != current.password,
          listener: (context, state) {
            _passwordController.text = state.password;
          },
        ),
        BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              previous.navigation != current.navigation,
          listener: (context, state) {
            switch (state.navigation) {
              case LoginNavigation.register:
                context.router.replace(const RegisterRoute());
              case LoginNavigation.tab:
                if (context.router.canPop()) {
                  context.router.maybePop();
                } else {
                  context.router.replace(TabRoute(pref: getIt()));
                }
              case LoginNavigation.none:
                break;
            }
          },
        ),
      ],
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Scaffold(
            body: WithViewState(
              viewState: state.viewState,
              retryAction: () {
                context.read<LoginBloc>().add(
                      const LoginEvent.didPressLogin(),
                    );
              },
              errorDisplayMode: ErrorDisplayMode.bottomSheet,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scaleValue(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: context.scaleValue(80)),
                        LoginTitleWidget(),
                        SizedBox(height: context.scaleValue(30)),
                        LoginInputFields(
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          userNameFocusNode: _userNameFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                        ),
                        SizedBox(height: context.scaleValue(64)),
                        AppButtonStyles.primaryPlatform(
                          context: context,
                          title: context.localization.login_view_login_button,
                          textStyle: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: context.colors.gray0),
                          onPressed: state.viewState == ViewState.loading
                              ? () {}
                              : () => _submit(context),
                        ),
                        SizedBox(height: context.scaleValue(24)),
                        LoginSignUp(),
                        SizedBox(height: context.scaleValue(10)),
                        AppButtonStyles.textPlatform(
                          context: context,
                          onPressed: () {
                            context.read<LoginBloc>().add(
                                  const LoginEvent.didPressOnContinueAsGuest(),
                                );
                          },
                          title:
                              context.localization.login_view_continue_as_guest,
                        ),
                        SizedBox(height: context.scaleValue(24)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<LoginBloc>().add(
          const LoginEvent.didPressLogin(),
        );
  }
}
