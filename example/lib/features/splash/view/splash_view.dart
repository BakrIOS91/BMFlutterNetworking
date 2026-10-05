import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/features/splash/bloc/splash_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';

@RoutePage()
class SplashView extends StatelessWidget implements AutoRouteWrapper {
  const SplashView({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SplashBloc>()..add(const SplashEvent.started()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listenWhen: (previous, current) =>
          current.navigation != SplashNavigation.none,
      listener: (context, state) {
        if (state.navigation == SplashNavigation.onboarding) {
          context.router.replace(const OnboardingRoute());
        } else if (state.navigation == SplashNavigation.tab) {
          context.router.replace(TabRoute(pref: getIt()));
        }
      },
      child: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.colors.primary800,
            body: WithViewState(
              viewState: state.viewState,
              errorDisplayMode: ErrorDisplayMode.bottomSheet,
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      context.imageConstants.splashLogo,
                      width: context.scaleValue(280),
                      height: context.scaleValue(203),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: context.scaleValue(50),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: context.scaleValue(2),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
