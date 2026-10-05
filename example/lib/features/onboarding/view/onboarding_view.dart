import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:flutter_example/features/onboarding/view/widgets/onboarding_button.dart';
import 'package:flutter_example/features/onboarding/view/widgets/step_indicator.dart';

@RoutePage()
class OnboardingView extends StatefulWidget implements AutoRouteWrapper {
  const OnboardingView({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingBloc>(),
      child: this,
    );
  }

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(const OnboardingEvent.loadPages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<OnboardingBloc, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.selectedIndex != current.selectedIndex,
            listener: (context, state) {
              _pageController.animateToPage(
                state.selectedIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
              );
            },
          ),
          BlocListener<OnboardingBloc, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.navigation != current.navigation,
            listener: (context, state) {
              if (state.navigation == OnboardingNavigation.tab) {
                context.router.replace(TabRoute(pref: getIt()));
              }
            },
          ),
        ],
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  onPageChanged: (index) {
                    context
                        .read<OnboardingBloc>()
                        .add(OnboardingEvent.changePage(index));
                  },
                  itemBuilder: (context, index) {
                    final page = state.pages[index];
                    return Stack(
                      children: [
                        Image.asset(
                          page.imagePath,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: context.scaleValue(80),
                  right: context.scaleValue(24),
                  left: context.scaleValue(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        state.currentPageData?.titleBuilder(context) ?? "",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: context.colors.white),
                      ),
                      SizedBox(height: context.scaleValue(8)),
                      Text(
                        state.currentPageData?.subtitleBuilder(context) ?? "",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: context.colors.white),
                      ),
                      SizedBox(height: context.scaleValue(24)),
                      StepIndicator(
                        currentPage: state.selectedIndex,
                        totalPages: state.pages.length,
                      ),
                      SizedBox(height: context.scaleValue(32)),
                      OnboardingButton(state: state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
