import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/features/auth/register/bloc/register_bloc.dart';
import 'package:flutter_example/features/auth/register/view/widgets/register_input_text_fields.dart';
import 'package:flutter_example/features/auth/register/view/widgets/register_login.dart';
import 'package:flutter_example/features/auth/register/view/widgets/register_title.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/status_view.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';

@RoutePage()
class RegisterView extends StatefulWidget implements AutoRouteWrapper {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<RegisterBloc>()..add(const RegisterEvent.started()),
      child: this,
    );
  }
}

class _RegisterViewState extends State<RegisterView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    final registerBloc = context.read<RegisterBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatusAlertDialog(
          status: Status.success,
          title: context.localization.create_account_success_title,
          message: context.localization.create_account_success_message,
          cancelButtonText: context.localization.commonDone,
        );
      },
    ).whenComplete(
      () {
        // This runs AFTER the dialog is dismissed
        registerBloc.add(const RegisterEvent.didPressOnDismiss());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (previous, current) =>
                previous.fullName != current.fullName,
            listener: (context, state) {
              _fullNameController.text = state.fullName;
            },
          ),
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (previous, current) => previous.email != current.email,
            listener: (context, state) {
              _emailController.text = state.email;
            },
          ),
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (previous, current) =>
                previous.password != current.password,
            listener: (context, state) {
              _passwordController.text = state.password;
            },
          ),
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (previous, current) =>
                !previous.successSignedUp && current.successSignedUp,
            listener: (context, state) {
              // This covers the case after updateProfileResponse success before navigation
              _showSuccessDialog(context);
            },
          ),
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (previous, current) =>
                previous.navigation != current.navigation,
            listener: (context, state) {
              switch (state.navigation) {
                case RegisterNavigation.tab:
                  if (context.router.canPop()) {
                    context.router.maybePop();
                  } else {
                    context.router.replace(TabRoute(pref: getIt()));
                  }
                case RegisterNavigation.login:
                  context.router.replace(const LoginRoute());
                case RegisterNavigation.none:
                  break;
              }
            },
          ),
        ],
        child: BlocBuilder<RegisterBloc, RegisterState>(
          builder: (context, state) {
            return WithViewState(
              viewState: state.viewState,
              errorDisplayMode: ErrorDisplayMode.bottomSheet,
              child: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleValue(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: context.scaleValue(80)),
                            RegisterTitleWidget(),
                            SizedBox(height: context.scaleValue(32)),
                            RegisterInputFields(
                              fullNameController: _fullNameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              fullNameFocusNode: _fullNameFocusNode,
                              emailFocusNode: _emailFocusNode,
                              passwordFocusNode: _passwordFocusNode,
                            ),
                            SizedBox(height: context.scaleValue(64)),
                            AppButtonStyles.primaryPlatform(
                              context: context,
                              title: context.localization
                                  .create_account_create_account_button_title,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: context.colors.gray0),
                              onPressed: state.viewState == ViewState.loading
                                  ? () {}
                                  : () => _submit(context),
                            ),
                            SizedBox(height: context.scaleValue(24)),
                            RegisterLoginWidget(),
                            SizedBox(height: context.scaleValue(24)),
                          ],
                        ),
                      ),
                    ),
                    if (state.successSignedUp)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            color: context.colors.gray0.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<RegisterBloc>().add(
          const RegisterEvent.didPressSignUp(),
        );
  }
}
