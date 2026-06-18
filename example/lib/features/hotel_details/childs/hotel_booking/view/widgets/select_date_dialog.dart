import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class HotelBookingSelectDateDialog extends StatefulWidget {
  const HotelBookingSelectDateDialog({
    super.key,
    required this.title,
    this.initialDate,
    this.firstDate,
  });

  final String title;
  final DateTime? initialDate;
  final DateTime? firstDate;

  static Future<DateTime?> show(
    BuildContext context, {
    required String title,
    DateTime? initialDate,
    DateTime? firstDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => HotelBookingSelectDateDialog(
        title: title,
        initialDate: initialDate,
        firstDate: firstDate,
      ),
    );
  }

  @override
  State<HotelBookingSelectDateDialog> createState() =>
      _HotelBookingSelectDateDialogState();
}

class _HotelBookingSelectDateDialogState
    extends State<HotelBookingSelectDateDialog> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedMonth = widget.initialDate ?? DateTime.now();
  }

  bool get _canGoToPreviousMonth {
    if (widget.firstDate == null) return true;
    final firstDateMonth =
        DateTime(widget.firstDate!.year, widget.firstDate!.month);
    final currentMonth = DateTime(_focusedMonth.year, _focusedMonth.month);
    return currentMonth.isAfter(firstDateMonth);
  }

  void _previousMonth() {
    if (!_canGoToPreviousMonth) return;
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  /// Returns days for the calendar grid, including leading/trailing overflow
  /// days from adjacent months (always non-null — nullable type removed).
  List<DateTime> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final leadingEmpties = firstDay.weekday % 7;
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0);

    final days = <DateTime>[];

    for (int i = leadingEmpties - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, prevMonth.day - i));
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    while (days.length % 7 != 0) {
      final last = days.last;
      days.add(DateTime(last.year, last.month, last.day + 1));
    }

    return days;
  }

  bool _isCurrentMonth(DateTime date) =>
      date.month == _focusedMonth.month && date.year == _focusedMonth.year;

  bool _isSelected(DateTime date) =>
      _selectedDate != null &&
      date.year == _selectedDate!.year &&
      date.month == _selectedDate!.month &&
      date.day == _selectedDate!.day;

  bool _isDisabled(DateTime date) {
    if (widget.firstDate == null) return false;
    final firstDate = DateTime(
      widget.firstDate!.year,
      widget.firstDate!.month,
      widget.firstDate!.day,
    );
    final comparisonDate = DateTime(date.year, date.month, date.day);
    return comparisonDate.isBefore(firstDate);
  }

  @override
  Widget build(BuildContext context) {
    final String locale = getIt<AppPreferences>().currentLanguage;
    final days = _buildCalendarDays();
    final weekDays = List.generate(7, (index) {
      final date = DateTime(2024, 1, 7 + index); // 2024-01-07 is a Sunday
      return DateFormat.E(locale).format(date);
    });

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scaleValue(20))),
      backgroundColor: context.colors.gray0,
      child: Padding(
        padding: EdgeInsetsDirectional.all(context.scaleValue(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.title,
              style: AppTextStyles.headlineMedium(
                context,
                color: context.colors.gray900,
              ),
            ),
            SizedBox(height: context.scaleValue(16)),
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.chevron_left,
                  onTap: _canGoToPreviousMonth ? _previousMonth : null,
                ),
                Text(
                  DateFormat('MMMM yyyy', locale).format(_focusedMonth),
                  style: AppTextStyles.titleMedium(
                    context,
                    color: context.colors.gray900,
                  ),
                ),
                _NavButton(icon: Icons.chevron_right, onTap: _nextMonth),
              ],
            ),
            SizedBox(height: context.scaleValue(16)),
            // Weekday headers
            Row(
              children: weekDays.map((d) {
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTextStyles.labelSmall(
                        context,
                        color: context.colors.gray600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: context.scaleValue(8)),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isCurrent = _isCurrentMonth(date);
                final isSelected = _isSelected(date);
                final isDisabled = _isDisabled(date);

                return GestureDetector(
                  onTap: (isDisabled || !isCurrent)
                      ? null
                      : () => setState(() => _selectedDate = date),
                  child: Container(
                    margin: const EdgeInsetsDirectional.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary800
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: isSelected
                            ? AppTextStyles.labelMedium(
                                context,
                                color: context.colors.gray0,
                              )
                            : AppTextStyles.labelSmall(
                                context,
                                color: isDisabled || !isCurrent
                                    ? context.colors.gray400
                                    : context.colors.gray900,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: context.scaleValue(16)),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.localization.commonCancel,
                      style: AppTextStyles.labelLarge(
                        context,
                        color: context.colors.alertError100,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scaleValue(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedDate == null
                        ? null
                        : () => Navigator.pop(context, _selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary800,
                      disabledBackgroundColor: context.colors.gray200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scaleValue(12)),
                      ),
                      padding:
                          EdgeInsetsDirectional.symmetric(vertical: context.scaleValue(14)),
                    ),
                    child: Text(
                      context.localization.common_apply,
                      style: AppTextStyles.labelLarge(
                        context,
                        color: context.colors.gray0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.scaleValue(36),
        height: context.scaleValue(36),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                onTap != null ? context.colors.gray200 : context.colors.gray100,
          ),
          color: context.colors.gray0,
        ),
        child: Icon(
          icon,
          size: context.scaleValue(20),
          color:
              onTap != null ? context.colors.gray900 : context.colors.gray300,
        ),
      ),
    );
  }
}
