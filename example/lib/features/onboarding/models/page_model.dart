import 'package:flutter/widgets.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class PageModel {
  final String imagePath;
  final String Function(BuildContext context) titleBuilder;
  final String Function(BuildContext context) subtitleBuilder;

  const PageModel({
    required this.imagePath,
    required this.titleBuilder,
    required this.subtitleBuilder,
  });
}

extension PageModelData on PageModel {
  static List<PageModel> get onboardingPages => [
        PageModel(
          titleBuilder: (context) => context.localization.onboarding_title_1,
          subtitleBuilder: (context) =>
              context.localization.onboarding_subtitle_1,
          imagePath: 'assets/images/on_boarding_1.jpg',
        ),
        PageModel(
          titleBuilder: (context) => context.localization.onboarding_title_2,
          subtitleBuilder: (context) =>
              context.localization.onboarding_subtitle_2,
          imagePath: 'assets/images/on_boarding_2.jpg',
        ),
        PageModel(
          titleBuilder: (context) => context.localization.onboarding_title_3,
          subtitleBuilder: (context) =>
              context.localization.onboarding_subtitle_3,
          imagePath: 'assets/images/on_boarding_3.jpg',
        ),
      ];
}
