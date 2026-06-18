import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_app_bar.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_booking_view.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_content_view.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';

@RoutePage()
class HotelDetailsView extends StatefulWidget implements AutoRouteWrapper {
  final Hotel hotel;

  const HotelDetailsView({
    super.key,
    required this.hotel,
  });

  @override
  State<HotelDetailsView> createState() => _HotelDetailsViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HotelDetailsBloc>(param1: hotel)
        ..add(const HotelDetailsEvent.started()),
      child: this,
    );
  }
}

class _HotelDetailsViewState extends State<HotelDetailsView> {
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();

    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    final bloc = context.read<HotelDetailsBloc>();
    bloc.add(
      HotelDetailsEvent.sheetSizeChanged(_sheetController.size),
    );
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const HotelDetailsBookingView(),
      body: BlocListener<HotelDetailsBloc, HotelDetailsState>(
        listenWhen: (previous, current) =>
            previous.navigationTo != current.navigationTo,
        listener: (context, state) {
          final navigationTo = state.navigationTo;
          if (navigationTo == null) return;

          switch (navigationTo) {
            case NavigationType.login:
              context.pushRoute(const LoginRoute());
            case NavigationType.facilities:
              context.pushRoute(
                FacilitiesListRoute(facilities: state.hotel.facilities ?? []),
              );
            case NavigationType.booking:
              context.pushRoute(
                HotelBookingRoute(hotel: state.hotel),
              );
          }

          context.read<HotelDetailsBloc>().add(
                const HotelDetailsEvent.resetNavigation(),
              );
        },
        child: BlocBuilder<HotelDetailsBloc, HotelDetailsState>(
          builder: (context, state) {
            final isDark = context.colors.isDark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: state.isCollapsed
                    ? (isDark ? Brightness.light : Brightness.dark)
                    : Brightness.light,
                statusBarBrightness: state.isCollapsed
                    ? (isDark ? Brightness.dark : Brightness.light)
                    : Brightness.dark,
              ),
              child: WithViewState(
                viewState: state.viewState,
                errorDisplayMode: ErrorDisplayMode.bottomSheet,
                child: Stack(
                  children: [
                    AppBarHeader(
                      imageUrl: state.hotel.image ?? "",
                    ),
                    DraggableScrollableSheet(
                      controller: _sheetController,
                      initialChildSize: 0.65,
                      minChildSize: 0.65,
                      maxChildSize: 1.0,
                      snap: true,
                      snapSizes: const [0.65, 1.0],
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: context.colors.gray0,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(context.scaleValue(30)),
                            ),
                          ),
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: SizedBox(height: context.scaleValue(16)),
                              ),
                              const HotelDetailsContentView(),
                            ],
                          ),
                        );
                      },
                    ),
                    HotelDetailsTopAppBar(
                      isCollapsed: state.isCollapsed,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
