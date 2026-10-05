import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/tab/childs/booking/bloc/booking_bloc.dart';
import 'package:flutter_example/utilities/reusables/search_view_bar.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/features/tab/childs/booking/view/widgets/booking_result_list.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.gray0,
      appBar: _buildAppBar(context),
      body: const SafeArea(
        child: _BookingBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        context.localization.tab_booking_title,
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

class _BookingBody extends StatelessWidget {
  const _BookingBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (prev, curr) =>
          prev.resultsViewState != curr.resultsViewState ||
              prev.bookings != curr.bookings ||
          prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        return WithViewState(
            viewState: state.viewState,
            child: Column(
              children: [
                _buildSearchBar(context, state.searchQuery),
                SizedBox(height: context.scaleValue(24)),
                Expanded(
                  child: WithViewState(
                      viewState: state.resultsViewState,
                      child: BookingResultList(
                        state: state,
                      )),
                ),
              ],
            ));
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, String searchQuery) {
    return Column(
      children: [
        SizedBox(height: context.scaleValue(20)),
        SearchViewBar(
          initialValue: searchQuery,
          showFilter: false,
          onSubmitted: (value) =>
              context.read<BookingBloc>().add(BookingEvent.queryChanged(value)),
          onClearTap: () =>
              context.read<BookingBloc>().add(const BookingEvent.clearSearch()),
        ),
      ],
    );
  }
}
