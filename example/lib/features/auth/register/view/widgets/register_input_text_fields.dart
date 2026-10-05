import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/auth/register/bloc/register_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/reusables/app_text_field.dart';

class RegisterInputFields extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode fullNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  const RegisterInputFields({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.fullNameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: context.localization.create_account_full_name_field,
              placeholder: context
                  .localization.create_account_full_name_field_placeholder,
              controller: fullNameController,
              focusNode: fullNameFocusNode,
              onChanged: (value) => context
                  .read<RegisterBloc>()
                  .add(RegisterEvent.fullNameChanged(value)),
              onSubmitted: (_) => emailFocusNode.requestFocus(),
              textInputAction: TextInputAction.next,
              errorText:
                  context.localization.create_account_full_name_empty_error,
              isError: state.fullNameIsError,
            ),
            SizedBox(height: context.scaleValue(16)),
            AppTextField(
              label: context.localization.login_view_email_label,
              placeholder: context.localization.login_view_email_placeholder,
              controller: emailController,
              focusNode: emailFocusNode,
              onChanged: (value) => context
                  .read<RegisterBloc>()
                  .add(RegisterEvent.emailChanged(value)),
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
                  .read<RegisterBloc>()
                  .add(RegisterEvent.passwordChanged(value)),
              onSubmitted: (_) => _submit(context),
              obscureText: !state.passwordVisible,
              errorText: context.localization.login_view_password_empty_error,
              isError: state.passwordIsError,
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
                    context.read<RegisterBloc>().add(
                        RegisterEvent.passwordVisibleChanged(
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
    context.read<RegisterBloc>().add(
          const RegisterEvent.didPressSignUp(),
        );
  }
}
