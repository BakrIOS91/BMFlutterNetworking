import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/auth/login/bloc/login_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

class LoginSignUp extends StatelessWidget {
  const LoginSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Row(
          spacing: context.scaleValue(5),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.localization.login_dont_have_account,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: context.colors.gray400),
            ),
            AppButtonStyles.textPlatform(
              context: context,
              onPressed: () {
                context.read<LoginBloc>().add(LoginEvent.didPressSignUp());
              },
              title: context.localization.login_sign_up,
            )
          ],
        );
      },
    );
  }
}
