import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/tab/childs/home/childs/search/bloc/search_bloc.dart';
import 'package:flutter_example/features/tab/childs/home/childs/search/view/widgets/search_result_list.dart';
import 'package:flutter_example/utilities/reusables/search_view_bar.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/features/filter_view/view/filter_by_view.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';

@RoutePage()
class SearchView extends StatefulWidget implements AutoRouteWrapper {
  const SearchView({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SearchBloc>()..add(const SearchEvent.started()),
      child: this,
    );
  }

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) =>
          previous.showFilerView != current.showFilerView,
      listener: (context, state) {
        if (state.showFilerView) {
          // Reset immediately to prevent a second modal if the filter button
          // is tapped again while this sheet is still open.
          context
              .read<SearchBloc>()
              .add(const SearchEvent.filterViewToggled(false));

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            showDragHandle: false,
            enableDrag: false,
            builder: (_) => FractionallySizedBox(
              heightFactor: 0.90,
              child: BlocProvider(
                create: (context) =>
                    getIt<FilterBloc>(param1: state.lastFilterRequest),
                child: const FilterByView(),
              ),
            ),
          ).then((result) {
            if (context.mounted) {
              final filterRequest =
                  result is FilterHotelsRequest ? result : null;
              context.read<SearchBloc>().add(
                    SearchEvent.filterIsDismissed(filterRequest),
                  );

              // Scroll to top if filter was reset (no active filters)
              if (filterRequest != null && !filterRequest.isFilterActive) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.gray0,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: _SearchBody(scrollController: _scrollController),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        context.localization.search_view_title,
        style: AppTextStyles.headlineMedium(
          context,
          color: context.colors.gray950,
        ),
      ),
      centerTitle: true,
      backgroundColor: context.colors.gray0,
      surfaceTintColor: context.colors.gray0,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}

class _SearchBody extends StatelessWidget {
  final ScrollController scrollController;
  const _SearchBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      // Explicitly exclude showFilerView / lastFilterRequest — those are handled
      // by the listener above and must not trigger a body rebuild (which would
      // re-run didUpdateWidget on SearchViewBar and disturb the text cursor).
      buildWhen: (prev, curr) =>
          prev.viewState != curr.viewState ||
          prev.searchResults != curr.searchResults ||
          prev.query != curr.query ||
          prev.lastFilterRequest != curr.lastFilterRequest,
      builder: (context, state) {
        return Column(
          children: [
            _buildSearchBar(context, state),
            SearchResultList(
              state: state,
              controller: scrollController,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchState state) {
    return Column(
      children: [
        SizedBox(height: context.scaleValue(20)),
        SearchViewBar(
          initialValue: state.query,
          onSubmitted: (value) => context.read<SearchBloc>().add(
                SearchEvent.requestSearch(),
              ),
          onChanged: (value) => context.read<SearchBloc>().add(
                SearchEvent.queryChanged(value),
              ),
          onClearTap: () => context.read<SearchBloc>().add(
                const SearchEvent.clearSearch(),
              ),
          onFilterTap: () {
            context
                .read<SearchBloc>()
                .add(const SearchEvent.filterViewToggled(true));
          },
          isFilterActive: state.lastFilterRequest?.isFilterActive ?? false,
        ),
      ],
    );
  }
}
