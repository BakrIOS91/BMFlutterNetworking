import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class LanguageSelectionBottomSheet extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelectionBottomSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: context.scaleValue(24.0)),
      child: Material(
        color: context.colors.gray0,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(
          Radius.circular(context.scaleValue(12.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                context.scaleValue(20.0),
                0,
                context.scaleValue(20.0),
                context.scaleValue(24.0),
              ),
              child: Column(
                children: [
                  _LanguageItem(
                    title: context.localization.setting_language_en,
                    isSelected: currentLanguage == 'en',
                    onTap: () => onLanguageSelected('en'),
                  ),
                  SizedBox(height: context.scaleValue(12)),
                  _LanguageItem(
                    title: context.localization.setting_language_ar,
                    isSelected: currentLanguage == 'ar',
                    onTap: () => onLanguageSelected('ar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(context.scaleValue(24.0)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            context.localization.setting_curent_language,
            style: AppTextStyles.titleLarge(context)
                .copyWith(color: context.colors.textGray0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.scaleValue(16.0)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.only(
          start: context.scaleValue(16.0),
          end: context.scaleValue(16.0),
          top: context.scaleValue(18.0),
          bottom: context.scaleValue(18.0),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.textPrimary800
              : context.colors.gray50,
          borderRadius: BorderRadius.circular(context.scaleValue(12.0)),
          border: Border.all(
            color: isSelected
                ? context.colors.additional0
                : context.colors.divider,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: context.scaleValue(24),
              height: context.scaleValue(24),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? context.colors.white
                        : context.colors.border,
                    width: 2,
                  ),
                  color: Colors.transparent),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: context.scaleValue(16),
                      color: context.colors.white,
                    )
                  : null,
            ),
            SizedBox(width: context.scaleValue(16)),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge(context).copyWith(
                    color: isSelected
                        ? context.colors.white
                        : context.colors.textGray700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
