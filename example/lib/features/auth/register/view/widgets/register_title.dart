import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class RegisterTitleWidget extends StatelessWidget {
  const RegisterTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.localization.create_account_title,
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(color: context.colors.gray900),
        ),
        SizedBox(height: context.scaleValue(8)),
        Text(
          context.localization.create_account_subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: context.colors.gray900),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
