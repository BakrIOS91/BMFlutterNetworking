import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class SearchViewBar extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClearTap;
  final bool showFilter;
  final bool isFilterActive;

  const SearchViewBar({
    super.key,
    this.initialValue,
    this.onSubmitted,
    this.onChanged,
    this.onFilterTap,
    this.onClearTap,
    this.showFilter = true,
    this.isFilterActive = false,
  });

  @override
  State<SearchViewBar> createState() => _SearchViewBarState();
}

class _SearchViewBarState extends State<SearchViewBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant SearchViewBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      // Use copyWith to preserve cursor at end instead of resetting to pos 0.
      final newText = widget.initialValue ?? '';
      _controller.value = _controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.scaleValue(52),
      margin: EdgeInsets.symmetric(horizontal: context.scaleValue(24)),
      decoration: BoxDecoration(
        color: context.colors.gray0,
        borderRadius: BorderRadius.circular(context.scaleValue(23.5)),
        border: Border.all(
          color: context.colors.border,
          width: context.scaleValue(1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: context.scaleValue(17.5)),
          AppIcon(
              asset: AppIcons.search,
              size: context.scaleValue(15),
              color: context.colors.textGray700),
          SizedBox(width: context.scaleValue(8)),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                FocusScope.of(context).unfocus();
                widget.onSubmitted?.call(value);
              },
              onChanged: (value) {
                setState(() {});
                widget.onChanged?.call(value);
              },
              style: AppTextStyles.bodyMedium(
                context,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : context.colors.gray950,
              ),
              decoration: InputDecoration(
                  hintText: context.localization.search_hint,
                  hintStyle: AppTextStyles.bodyMedium(
                    context,
                    color: context.colors.textGray700,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.transparent,
                  suffixIconConstraints: const BoxConstraints(),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.cancel,
                            size: context.scaleValue(18),
                            color: context.colors.textGray700,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                            widget.onClearTap?.call();
                          },
                        )
                      : null),
            ),
          ),
          if (widget.showFilter) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppButtonStyles.iconButtonPlatform(
                  context: context,
                  onPressed: widget.onFilterTap ?? () {},
                  icon: AppIcon(
                    asset: AppIcons.filterIcon,
                    size: context.scaleValue(20),
                    color: widget.isFilterActive
                        ? context.colors.primary500
                        : context.colors.textGray0,
                  ),
                ),
                if (widget.isFilterActive)
                  Positioned(
                    top: context.scaleValue(4),
                    right: context.scaleValue(4),
                    child: Container(
                      width: context.scaleValue(15),
                      height: context.scaleValue(15),
                      decoration: BoxDecoration(
                        color: context.colors.alertError100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.gray0,
                          width: context.scaleValue(1.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: context.scaleValue(8)),
          ] else
            SizedBox(width: context.scaleValue(8)),
        ],
      ),
    );
  }
}
