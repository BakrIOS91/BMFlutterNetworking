import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/auth/register/bloc/register_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

class RegisterLoginWidget extends StatelessWidget {
  const RegisterLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Row(
          spacing: context.scaleValue(5),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.localization.create_account_login,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: context.colors.gray400),
            ),
            AppButtonStyles.textPlatform(
              context: context,
              onPressed: () {
                context
                    .read<RegisterBloc>()
                    .add(RegisterEvent.didPressOnSignIn());
              },
              title: context.localization.login_view_login_button,
            )
          ],
        );
      },
    );
  }
}
