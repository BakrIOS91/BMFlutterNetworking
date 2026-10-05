import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class InstantBookWidget extends StatelessWidget {
  const InstantBookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      buildWhen: (prev, curr) =>
          prev.selection.pInstantBook != curr.selection.pInstantBook,
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localization.filter_instant_book_title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.colors.grayScale,
                        ),
                  ),
                  SizedBox(height: context.scaleValue(4)),
                  Text(
                    context.localization.filter_instant_book_subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.subTitleColor,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.scaleValue(12)),
            Switch(
              value: state.selection.pInstantBook,
              onChanged: (_) {
                context.read<FilterBloc>().add(
                      const FilterEvent.instantBookToggled(),
                    );
              },
              activeThumbColor: context.colors.primary800,
              inactiveThumbColor: context.colors.white,
              inactiveTrackColor: context.colors.gray900.withValues(alpha: 0.2),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        );
      },
    );
  }
}
