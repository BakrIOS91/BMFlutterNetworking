import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/tab/childs/setting/bloc/settings_bloc.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';

class SettingsTabList extends StatelessWidget {
  const SettingsTabList({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, context.localization.commonSettings),
        SizedBox(height: context.scaleValue(16)),
        _SettingItem(
          icon: AppIcons.languageIcon,
          title: context.localization.setting_curent_language,
          onTap: () => bloc.add(SettingsEvent.didPressOnChangeLanguage()),
        ),
        _divider(context),
        _SettingItem(
          icon: AppIcons.themeIcon,
          title: bloc.state.theme == ThemeMode.dark
              ? context.localization.setting_theme_dark
              : context.localization.setting_theme_light,
          onTap: () => bloc.add(SettingsEvent.didPressOnChangeTheme()),
        ),
        _divider(context),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium(context).copyWith(
        color: context.colors.gray400,
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: context.scaleValue(48)),
      child: Divider(
        color: context.colors.divider,
        height: 1,
        thickness: 1,
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsetsDirectional.symmetric(vertical: context.scaleValue(16)),
        child: Row(
          children: [
            AppIcon(
              asset: icon,
              size: context.scaleValue(28),
              color: context.colors.gray900,
            ),
            SizedBox(width: context.scaleValue(20)),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium(context).copyWith(
                  color: context.colors.gray900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
