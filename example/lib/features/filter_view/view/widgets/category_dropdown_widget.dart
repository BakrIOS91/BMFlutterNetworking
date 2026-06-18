import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class CategoryDropdownWidget extends StatelessWidget {
  const CategoryDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      buildWhen: (prev, curr) =>
          prev.selection.catId != curr.selection.catId ||
          prev.categories != curr.categories,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localization.filter_category_label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.colors.grayScale,
                  ),
            ),
            SizedBox(height: context.scaleValue(10)),
            DropdownMenu<int>(
              initialSelection: state.selection.catId,
              expandedInsets: EdgeInsets.zero,
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.grayScale,
                  ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: context.colors.gray0,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.scaleValue(16),
                  vertical: context.scaleValue(14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scaleValue(15)),
                  borderSide: BorderSide(color: context.colors.textFieldBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scaleValue(15)),
                  borderSide: BorderSide(color: context.colors.textFieldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scaleValue(15)),
                  borderSide: BorderSide(color: context.colors.textFieldBorder),
                ),
              ),
              dropdownMenuEntries:
                  state.categories.where((c) => c.id != null).map((category) {
                return DropdownMenuEntry<int>(
                  value: category.id ?? 0,
                  label: category.title ?? '',
                );
              }).toList(),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(context.colors.gray0),
              ),
              onSelected: (value) {
                if (value != null) {
                  context.read<FilterBloc>().add(
                        FilterEvent.categoryChanged(value),
                      );
                }
              },
            )
          ],
        );
      },
    );
  }
}
