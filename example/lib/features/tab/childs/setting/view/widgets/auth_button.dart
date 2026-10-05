import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/tab/childs/setting/bloc/settings_bloc.dart';
import 'package:flutter_example/utilities/reusables/status_view.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';

class AuthActionButton extends StatelessWidget {
  final bool isLoggedIn;

  const AuthActionButton({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;

    final child = isLoggedIn
        ? AppButtonStyles.textPlatform(
            context: context,
            title: localization.commonLogout,
            textStyle: AppTextStyles.titleMedium(context).copyWith(
              color: context.colors.alertError100,
            ),
            onPressed: () => _showLogoutDialog(context),
          )
        : AppButtonStyles.textPlatform(
            context: context,
            title: localization.settings_login_button,
            textStyle: AppTextStyles.titleMedium(context).copyWith(
              color: context.colors.primary800,
            ),
            onPressed: () async {
              await context.router.push(const LoginRoute());
              if (context.mounted) {
                context.read<SettingsBloc>().add(const SettingsEvent.started());
              }
            },
          );

    return Center(child: child);
  }

  void _showLogoutDialog(BuildContext context) {
    final bloc = context.read<SettingsBloc>();

    showDialog(
      context: context,
      builder: (_) => StatusAlertDialog(
        status: Status.question,
        title: context.localization.settings_logout_confirmation_title,
        message: context.localization.settings_logout_confirmation_message,
        buttonText: context.localization.commonLogout,
        cancelButtonText: context.localization.commonCancel,
        isDistructive: true,
        action: () => bloc.add(const SettingsEvent.didPressLogOut()),
      ),
    );
  }
}
