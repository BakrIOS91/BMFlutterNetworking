import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/tab/childs/home/bloc/home_bloc.dart';
import 'package:flutter_example/features/tab/childs/home/view/widgets/popular_property_list/popular_properties_list.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:flutter_example/utilities/reusables/profile_header.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/features/tab/childs/home/view/search_button.dart';
import 'package:flutter_example/utilities/reusables/paginated_list.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/reusables/section_header.dart';
import 'package:flutter_example/utilities/reusables/property_category_list/property_category_list.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/horizontal_property_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_example/utilities/reusables/app_error_view.dart';

class HomeView extends StatelessWidget {
  final AppPreferences _pref;
  const HomeView({super.key, required AppPreferences pref}) : _pref = pref;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        PreferencesListener(
          listenTo: _pref.userProfileNotifier,
          listener: (context, profile) {
            if (profile != null) {
              context.read<HomeBloc>().add(const HomeEvent.profileUpdated());
            }
          },
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.isInitializing != current.isInitializing ||
            _appBarBuildWhen(previous, current),
        builder: (context, state) {
          if (state.isInitializing) {
            return Scaffold(
              backgroundColor: context.colors.gray0,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            appBar: _buildAppBar(context, state),
            body: SafeArea(
              child: WithViewState(
                viewState: state.viewState,
                isRefreshable: !Platform.isIOS,
                retryAction: () => context.read<HomeBloc>().refreshHomeData(),
                child: const _HomeContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _appBarBuildWhen(HomeState previous, HomeState current) {
    return previous.viewState != current.viewState ||
        previous.name != current.name ||
        previous.location != current.location ||
        previous.avatarUrl != current.avatarUrl;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HomeState state) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: context.scaleValue(70),
      backgroundColor: context.colors.gray0,
      surfaceTintColor: context.colors.gray0,
      title: ProfileHeader(
        title:
            state.name.isEmpty ? context.localization.common_guest : state.name,
        subtitle: state.location,
        avatarUrl: state.avatarUrl,
        subtitleIcon: AppIcons.location,
        trailing: const SearchButton(),
        onTap: () async {
          if (state.isLoggedIn) {
            await context.router.push(const AccountInfoRoute());
          } else {
            await context.router.push(const LoginRoute());
          }
          if (context.mounted) {
            context.read<HomeBloc>().add(const HomeEvent.refresh());
          }
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) => _contentBuildWhen(previous, current),
      builder: (context, state) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
        final bloc = context.read<HomeBloc>();

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (isIOS)
              CupertinoSliverRefreshControl(
                onRefresh: bloc.refreshHomeData,
              ),
            // Popular Properties Section
            SliverToBoxAdapter(child: _buildPopularList(context, state)),

            // Recommended Properties Header & Categories (Title + Categories)
            if (state.isLoggedIn) ...[
              SliverToBoxAdapter(
                child: _buildRecommendedHeader(context, state),
              ),

              // Recommended Items List as a Paginated Sliver
              _buildRecommendedSliverList(context, state),
            ],

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  bool _contentBuildWhen(HomeState previous, HomeState current) {
    return previous.isLoggedIn != current.isLoggedIn ||
        previous.popularProperties != current.popularProperties ||
        previous.recommendedProperties != current.recommendedProperties ||
        previous.selectedCategoryIndex != current.selectedCategoryIndex ||
        previous.categories != current.categories ||
        previous.popularViewState != current.popularViewState ||
        previous.recommendedViewState != current.recommendedViewState;
  }

  Widget _buildPopularList(BuildContext context, HomeState state) {
    return Column(
      children: [
        SizedBox(height: context.scaleValue(16)),
        if (state.popularProperties.isNotEmpty ||
            state.popularViewState != ViewState.loaded)
          WithViewState(
            viewState: state.popularViewState,
            retryAction: () => context
                .read<HomeBloc>()
                .add(const HomeEvent.requestPopularHotels()),
            child: state.popularProperties.isEmpty
                ? const SizedBox.shrink()
                : PopularPropertiesSection(
                    properties: state.popularProperties,
                    onSeeAllPressed: () async {
                      await context.router.push(const PopularItemsRoute());
                      if (context.mounted) {
                        context.read<HomeBloc>().add(const HomeEvent.refresh());
                      }
                    },
                    onPropertyTap: (hotel) async {
                      await context.router
                          .push(HotelDetailsRoute(hotel: hotel));

                      if (context.mounted) {
                        context.read<HomeBloc>().add(const HomeEvent.refresh());
                      }
                    },
                    onFavoriteTap: (hotel) async {
                      if (state.isLoggedIn) {
                        context
                            .read<HomeBloc>()
                            .add(HomeEvent.requestToggleFavorite(hotel));
                      } else {
                        await context.router.push(const LoginRoute());
                        if (context.mounted) {
                          context
                              .read<HomeBloc>()
                              .add(const HomeEvent.refresh());
                        }
                      }
                    },
                  ),
          ),
      ],
    );
  }

  Widget _buildRecommendedHeader(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.scaleValue(16)),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
              horizontal: context.scaleValue(24.0)),
          child: SectionHeader(
            title: context.localization.home_recommended_section_title,
          ),
        ),
        SizedBox(height: context.scaleValue(16.0)),
        if (state.categories.isNotEmpty) ...[
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                context.scaleValue(16.0), 0, 0.0, 0.0),
            child: PropertyCategoryList(
              categories: state.categories,
              selectedIndex: state.selectedCategoryIndex,
              onSelected: (index) =>
                  context.read<HomeBloc>().add(HomeEvent.selectCategory(index)),
            ),
          ),
          SizedBox(height: context.scaleValue(16.0)),
        ],
      ],
    );
  }

  Widget _buildRecommendedSliverList(BuildContext context, HomeState state) {
    if (state.recommendedViewState is Loading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.recommendedViewState is! Loading &&
        state.recommendedViewState != ViewState.loaded &&
        state.recommendedViewState is! NoData) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(
          title: context.localization.commonRetry,
          message: context.localization.serverErrorMessage,
          mainActionTitle: context.localization.commonRetry,
          onMainAction: () => context.read<HomeBloc>().add(
              const HomeEvent.requestRecommendedHotels(page: AtPage.first)),
        ),
      );
    }

    return PaginatedSliverList<Hotel>(
      items: state.recommendedProperties,
      shouldPaginate: state.recommendedShouldPaginate,
      onPaginate: context.read<HomeBloc>().paginateRecommended,
      itemBuilder: (context, hotel, index) {
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(
              horizontal: context.scaleValue(24.0)),
          child: Column(
            children: [
              HorizontalPropertyCard(
                property: hotel,
                onFavoriteTap: () {
                  context
                      .read<HomeBloc>()
                      .add(HomeEvent.requestToggleFavorite(hotel));
                },
                onTap: () async {
                  await context.router.push(HotelDetailsRoute(hotel: hotel));

                  if (context.mounted) {
                    context.read<HomeBloc>().add(const HomeEvent.refresh());
                  }
                },
              ),
              if (index < state.recommendedProperties.length - 1)
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                      vertical: context.scaleValue(16.0)),
                  child: Divider(
                    height: context.scaleValue(1),
                    color: context.colors.border,
                  ),
                ),
            ],
          ),
        );
      },
      emptyView: SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(
          title: context.localization.noDataErrorTitle,
          message: context.localization.noDataErrorMessage,
        ),
      ),
    );
  }
}
