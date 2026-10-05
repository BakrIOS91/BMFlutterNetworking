import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class RatingsWidget extends StatelessWidget {
  const RatingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      buildWhen: (prev, curr) =>
          prev.selection.minRating != curr.selection.minRating,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localization.filter_ratings_title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.colors.grayScale,
                  ),
            ),
            SizedBox(height: context.scaleValue(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final rating = 5 - index;
                final isSelected = state.selection.minRating == rating;
                return GestureDetector(
                  onTap: () {
                    context.read<FilterBloc>().add(
                          FilterEvent.ratingSelected(rating),
                        );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scaleValue(12),
                      vertical: context.scaleValue(10),
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.gray0,
                      borderRadius: BorderRadius.circular(context.scaleValue(12)),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary800
                            : context.colors.filterNotSelectedColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: context.colors.ratingColor,
                          size: context.scaleValue(18),
                        ),
                        SizedBox(width: context.scaleValue(4)),
                        Text(
                          '$rating',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: context.colors.grayScale,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
