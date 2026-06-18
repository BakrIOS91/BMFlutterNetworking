import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/auth/login/bloc/login_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/reusables/app_text_field.dart';

class LoginInputFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode userNameFocusNode;
  final FocusNode passwordFocusNode;

  const LoginInputFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.userNameFocusNode,
    required this.passwordFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: context.localization.login_view_email_label,
              placeholder: context.localization.login_view_email_placeholder,
              controller: usernameController,
              focusNode: userNameFocusNode,
              onChanged: (value) => context
                  .read<LoginBloc>()
                  .add(LoginEvent.usernameChanged(value)),
              onSubmitted: (_) => passwordFocusNode.requestFocus(),
              textInputAction: TextInputAction.next,
              errorText: state.emailErrorType == EmailErrorType.empty
                  ? context.localization.login_view_username_empty_error
                  : context.localization.login_view_email_format_error,
              isError: state.emailErrorType.isError,
            ),
            SizedBox(height: context.scaleValue(16)),
            AppTextField(
              label: context.localization.login_view_password_label,
              placeholder: context.localization.login_view_password_placeholder,
              controller: passwordController,
              focusNode: passwordFocusNode,
              onChanged: (value) => context
                  .read<LoginBloc>()
                  .add(LoginEvent.passwordChanged(value)),
              onSubmitted: (_) => _submit(context),
              obscureText: !state.passwordVisible,
              errorText: context.localization.login_view_password_empty_error,
              isError: state.passwordError,
              textInputAction: TextInputAction.done,
              suffixIcon: Transform.scale(
                scaleX: -1,
                child: AppButtonStyles.iconButtonPlatform(
                  context: context,
                  icon: Icon(
                    state.passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    context.read<LoginBloc>().add(
                        LoginEvent.passwordVisibleChanged(
                            state.passwordVisible ? false : true));
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _submit(BuildContext context) {
    context.read<LoginBloc>().add(
          const LoginEvent.didPressLogin(),
        );
  }
}
