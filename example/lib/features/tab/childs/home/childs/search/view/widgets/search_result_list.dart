import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/features/tab/childs/home/childs/search/bloc/search_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/vertical_property_card.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:flutter_example/utilities/reusables/paginated_list.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

class SearchResultList extends StatelessWidget {
  final SearchState state;
  final ScrollController? controller;

  const SearchResultList({
    required this.state,
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: context.scaleValue(12)),
          Expanded(
            child: WithViewState(
              viewState: state.viewState,
              retryAction: () => context
                  .read<SearchBloc>()
                  .add(const SearchEvent.requestSearch()),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: context.scaleValue(20)),
                child: PaginatedList<Hotel>(
                  controller: controller,
                  items: state.searchResults,
                  shouldPaginate: state.shouldPaginate,
                  onRefresh: context.read<SearchBloc>().refresh,
                  onPaginate: context.read<SearchBloc>().paginate,
                  itemBuilder: (context, property, index) {
                    return VerticalPropertyCard(
                      property: property,
                      onFavoriteTap: () async {
                        if (state.isLoggedIn) {
                          context
                              .read<SearchBloc>()
                              .add(SearchEvent.didTapToggleFavorite(property));
                        } else {
                          await context.router.push(const LoginRoute());
                          if (context.mounted) {
                            context.read<SearchBloc>().add(
                                  SearchEvent.started(),
                                );
                          }
                        }
                      },
                      onTap: () async {
                        await context.router
                            .push(HotelDetailsRoute(hotel: property));
                        if (context.mounted) {
                          context.read<SearchBloc>().add(
                                SearchEvent.requestSearch(),
                              );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
