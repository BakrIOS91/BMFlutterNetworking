import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class PriceRangeWidget extends StatelessWidget {
  const PriceRangeWidget({super.key});

  static const double _maxPrice = 200.0;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = context.colors.primary800;

    return BlocBuilder<FilterBloc, FilterState>(
      buildWhen: (prev, curr) =>
          prev.selection.minPrice != curr.selection.minPrice ||
          prev.selection.maxPrice != curr.selection.maxPrice,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.localization.filter_price_label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.colors.grayScale,
                      ),
                ),
                Text(
                  '\$${state.selection.minPrice} - \$${state.selection.maxPrice}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.subTitleColor,
                      ),
                ),
              ],
            ),
            SizedBox(height: context.scaleValue(8)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: activeColor,
                inactiveTrackColor: context.colors.filterNotSelectedColor,
                thumbColor: activeColor,
                overlayColor: activeColor.withValues(alpha: 0.15),
                thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: context.scaleValue(10)),
                trackHeight: 3,
                rangeThumbShape: RoundRangeSliderThumbShape(
                  enabledThumbRadius: context.scaleValue(10),
                ),
              ),
              child: RangeSlider(
                values: RangeValues(state.selection.minPrice.toDouble(),
                    state.selection.maxPrice.toDouble()),
                min: 0,
                max: _maxPrice,
                onChanged: (values) {
                  context.read<FilterBloc>().add(
                        FilterEvent.priceChanged(values.start, values.end),
                      );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
