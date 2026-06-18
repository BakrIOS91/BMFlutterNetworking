import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/tab/childs/setting/bloc/settings_bloc.dart';
import 'package:flutter_example/features/tab/childs/setting/view/widgets/auth_button.dart';
import 'package:flutter_example/utilities/reusables/profile_header.dart';
import 'package:flutter_example/features/tab/childs/setting/view/widgets/settings_tab_list.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

import 'package:flutter_example/features/tab/childs/setting/view/widgets/language_selection_bottom_sheet.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.gray0,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
              horizontal: context.scaleValue(20.0),
              vertical: context.scaleValue(24.0)),
          child: BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                current.showLanguagePicker && !previous.showLanguagePicker,
            listener: (context, state) {
              if (state.showLanguagePicker) {
                _showLanguageDialog(context, state);
              }
            },
            child: const _SettingsBody(),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        context.localization.tab_profile_title,
        style: AppTextStyles.titleLarge(context).copyWith(
          color: context.colors.gray950,
        ),
      ),
      centerTitle: true,
      backgroundColor: context.colors.gray0,
      surfaceTintColor: context.colors.gray0,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      fullscreenDialog: false,
      barrierDismissible: true,
      builder: (ctx) => LanguageSelectionBottomSheet(
        currentLanguage: state.currentLanguage,
        onLanguageSelected: (langCode) {
          context
              .read<SettingsBloc>()
              .add(SettingsEvent.didSelectLanguage(langCode));
          Navigator.pop(ctx);
        },
      ),
    ).then((_) {
      if (context.mounted) {
        context
            .read<SettingsBloc>()
            .add(const SettingsEvent.resetLanguagePicker());
      }
    });
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(
              title: state.isLoggedIn
                  ? context.localization.settings_welcome_title(
                      state.name.isNotEmpty
                          ? state.name
                          : context.localization.settings_user_placeholder)
                  : context.localization.settings_welcome_title(
                      context.localization.common_guest),
              subtitle: state.isLoggedIn
                  ? (state.email.isNotEmpty
                      ? state.email
                      : context.localization.settings_logged_in_subtitle)
                  : context.localization.settings_guest_subtitle,
              avatarUrl: state.avatarUrl,
              avatarSize: 56.0,
              onTap: () async {
                if (state.isLoggedIn) {
                  await context.router.push(const AccountInfoRoute());
                } else {
                  await context.router.push(const LoginRoute());
                }
                if (context.mounted) {
                  context
                      .read<SettingsBloc>()
                      .add(const SettingsEvent.started());
                }
              },
            ),
            SizedBox(height: context.scaleValue(48)),
            const SettingsTabList(),
            SizedBox(height: context.scaleValue(20)),
            AuthActionButton(isLoggedIn: state.isLoggedIn),
            SizedBox(height: context.scaleValue(20)),
          ],
        );
      },
    );
  }
}
