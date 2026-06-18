import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/tab/childs/home/childs/popular_items/bloc/popular_items_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/paginated_list.dart';
import 'package:flutter_example/utilities/reusables/vertical_property_card.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';

@RoutePage()
class PopularItemsView extends StatelessWidget implements AutoRouteWrapper {
  const PopularItemsView({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PopularItemsBloc>()..add(const PopularItemsEvent.started()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.gray0,
      appBar: AppBar(
        title: Text(
          context.localization.home_popular_section_title,
          style: AppTextStyles.titleLarge(context).copyWith(
            color: context.colors.gray950,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colors.gray0,
        surfaceTintColor: context.colors.gray0,
        elevation: 0,
      ),
      body: BlocBuilder<PopularItemsBloc, PopularItemsState>(
        builder: (context, state) {
          return WithViewState(
            viewState: state.viewState,
            retryAction: () => context
                .read<PopularItemsBloc>()
                .add(const PopularItemsEvent.requestPopularItems(AtPage.first)),
            child: SafeArea(
              child: PaginatedList<Hotel>(
                items: state.items,
                shouldPaginate: state.shouldPaginate,
                onRefresh: context.read<PopularItemsBloc>().refresh,
                onPaginate: context.read<PopularItemsBloc>().paginate,
                itemBuilder: (context, hotel, index) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: context.scaleValue(20),
                      end: context.scaleValue(20),
                      bottom: context.scaleValue(12),
                      top: index == 0 ? context.scaleValue(12) : 0,
                    ),
                    child: VerticalPropertyCard(
                      property: hotel,
                      onFavoriteTap: () async {
                        if (state.isLoggedIn) {
                          context.read<PopularItemsBloc>().add(
                                PopularItemsEvent.didTapToggleFavorite(hotel),
                              );
                        } else {
                          await context.router.push(const LoginRoute());
                          if (context.mounted) {
                            context
                                .read<PopularItemsBloc>()
                                .add(const PopularItemsEvent.started());
                          }
                        }
                      },
                      onTap: () async {
                        await context.router
                            .push(HotelDetailsRoute(hotel: hotel));
                        if (context.mounted) {
                          context.read<PopularItemsBloc>().add(
                                const PopularItemsEvent.requestPopularItems(
                                    AtPage.first),
                              );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
