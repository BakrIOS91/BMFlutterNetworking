import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:intl/intl.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class HotelBookingDateCardWidget extends StatelessWidget {
  const HotelBookingDateCardWidget({
    super.key,
    required this.label,
    this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String locale = getIt<AppPreferences>().currentLanguage;
    final formattedDate = date != null
        ? DateFormat('MMM dd, yyyy', locale).format(date!)
        : context.localization.booking_view_select_date_in_title;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: context.scaleValue(14),
            vertical: context.scaleValue(14),
          ),
          decoration: BoxDecoration(
            color: context.colors.gray50,
            borderRadius: BorderRadius.circular(context.scaleValue(14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIcon(
                    asset: AppIcons.calendarIcon,
                    size: context.scaleValue(18),
                    color: context.colors.gray900,
                  ),
                  SizedBox(width: context.scaleValue(6)),
                  Text(
                    label,
                    style: AppTextStyles.titleSmall(
                      context,
                      color: context.colors.gray900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.scaleValue(6)),
              Text(
                formattedDate,
                style: AppTextStyles.bodySmall(
                  context,
                  color: date != null
                      ? context.colors.gray600
                      : context.colors.gray400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
