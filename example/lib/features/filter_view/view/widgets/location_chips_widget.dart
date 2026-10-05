import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class LocationChipsWidget extends StatelessWidget {
  const LocationChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      buildWhen: (prev, curr) =>
          prev.selection.cityName != curr.selection.cityName ||
          prev.cities != curr.cities,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localization.filter_location_title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.colors.grayScale,
                  ),
            ),
            SizedBox(height: context.scaleValue(12)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: state.cities.map((city) {
                  final isSelected = state.selection.cityName == city.name;
                  return Padding(
                    padding: EdgeInsets.only(right: context.scaleValue(10)),
                    child: InkWell(
                      onTap: () {
                        context.read<FilterBloc>().add(
                              FilterEvent.locationSelected(city.name ?? ""),
                            );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.primary800
                              : context.colors.gray0,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primary800
                                : context.colors.filterNotSelectedColor,
                          ),
                        ),
                        child: Text(
                          city.name ?? '',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isSelected
                                        ? context.colors.gray0
                                        : context.colors.primary800,
                                  ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
