import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_input_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.keyboardType,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputTextStyle,
    this.isError = false,
    this.errorText,
  });

  final String label;
  final String? placeholder;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final String? Function(String?)? validator;

  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextStyle? inputTextStyle;

  /// Flag to indicate if this field is in error state
  final bool isError;

  /// Optional custom error text
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final displayedErrorText = isError ? errorText ?? "Invalid input" : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle(context, label),
        SizedBox(height: context.scaleValue(8)),
        TextFormField(
          style: (inputTextStyle ?? Theme.of(context).textTheme.titleSmall)
              ?.copyWith(
            color: enabled
                ? context.colors.gray700
                : context.colors.disabledInputText,
          ),
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          decoration: AppInputStyles.decoration(
            context,
            placeholder: placeholder,
            error: displayedErrorText,
            isError: isError,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }

  Widget _fieldTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(left: context.scaleValue(5.0)),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: context.colors.gray800),
      ),
    );
  }
}
