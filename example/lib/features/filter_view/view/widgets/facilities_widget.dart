import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class FacilitiesWidget extends StatelessWidget {
  const FacilitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      buildWhen: (prev, curr) =>
          prev.facilities != curr.facilities ||
          prev.selection.facilitiesIds != curr.selection.facilitiesIds,
      builder: (context, state) {
        if (state.facilities.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localization.filter_facilities_title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.colors.grayScale,
                  ),
            ),
            const SizedBox(height: 8),
            ...state.facilities.map((facility) {
              final isSelected = facility.id != null &&
                  state.selection.facilitiesIds.contains(facility.id);
              return _FacilityItem(
                key: ValueKey(facility.id),
                label: facility.title ?? '',
                isChecked: isSelected,
                onTap: () {
                  if (facility.id != null) {
                    context.read<FilterBloc>().add(
                          FilterEvent.facilityToggled(facility.id!),
                        );
                  }
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _FacilityItem extends StatelessWidget {
  const _FacilityItem({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onTap,
  });

  final String label;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scaleValue(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.subTitleColor,
                  ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isChecked ? context.colors.primary800 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked
                      ? context.colors.primary800
                      : context.colors.subTitleColor,
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? Icon(Icons.check,
                      color: context.colors.white, size: context.scaleValue(16))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
