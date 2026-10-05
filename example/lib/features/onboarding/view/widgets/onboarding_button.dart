import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/features/onboarding/bloc/onboarding_bloc.dart';

class OnboardingButton extends StatelessWidget {
  final OnboardingState state;

  const OnboardingButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isLastPage = state.selectedIndex == state.pages.length - 1;

    return SizedBox(
      width: double.infinity,
      height: context.scaleValue(58),
      child: AppButtonStyles.primaryPlatform(
        context: context,
        title: isLastPage
            ? context.localization.common_get_started
            : context.localization.common_continue,
        textStyle: Theme.of(context)
            .textTheme
            .headlineLarge
            ?.copyWith(color: context.colors.white),
        onPressed: () {
          if (isLastPage) {
            context
                .read<OnboardingBloc>()
                .add(const OnboardingEvent.getStartedPressed());
          } else {
            context
                .read<OnboardingBloc>()
                .add(OnboardingEvent.changePage(state.selectedIndex + 1));
          }
        },
      ),
    );
  }
}
