import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/features/filter_view/view/widgets/category_dropdown_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/price_range_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/instant_book_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/location_chips_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/facilities_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/ratings_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/apply_filter_button_widget.dart';
import 'package:flutter_example/features/filter_view/view/widgets/reset_filter_button_widget.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';

class FilterByView extends StatelessWidget {
  const FilterByView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: context.colors.gray0,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(context.scaleValue(24))),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.only(
                top: context.scaleValue(12), bottom: context.scaleValue(8)),
            child: Container(
              width: context.scaleValue(40),
              height: context.scaleValue(4),
              decoration: BoxDecoration(
                color: context.colors.gray300,
                borderRadius: BorderRadius.circular(context.scaleValue(2)),
              ),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.scaleValue(8)),
            child: Text(
              context.localization.filter_category_title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: context.scaleValue(18),
                    color: context.colors.grayScale,
                  ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.scaleValue(32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.scaleValue(8)),
                  const CategoryDropdownWidget(),
                  SizedBox(height: context.scaleValue(24)),
                  const PriceRangeWidget(),
                  SizedBox(height: context.scaleValue(24)),
                  const InstantBookWidget(),
                  SizedBox(height: context.scaleValue(24)),
                  const LocationChipsWidget(),
                  SizedBox(height: context.scaleValue(24)),
                  const FacilitiesWidget(),
                  SizedBox(height: context.scaleValue(24)),
                  const RatingsWidget(),
                  SizedBox(height: context.scaleValue(32)),
                  // Fine-grained builder only for the action buttons,
                  // which need state.selection to pass back on Apply.
                  BlocBuilder<FilterBloc, FilterState>(
                    buildWhen: (prev, curr) => prev.selection != curr.selection,
                    builder: (context, state) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ApplyFilterButtonWidget(
                              onApply: () {
                                Navigator.of(context).pop(state.selection);
                              },
                            ),
                          ),
                          SizedBox(width: context.scaleValue(16)),
                          Expanded(
                            flex: 1,
                            child: ResetFilterButtonWidget(
                              onReset: () {
                                Navigator.of(context)
                                    .pop(const FilterHotelsRequest());
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: context.scaleValue(24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
