import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/features/hotel_details/childs/facilities_list/bloc/facilities_list_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/childs/facilities_list/view/widgets/facility_expansion_tile.dart';

@RoutePage()
class FacilitiesListView extends StatelessWidget implements AutoRouteWrapper {
  final List<Facility> facilities;
  const FacilitiesListView({super.key, required this.facilities});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FacilitiesListBloc>(param1: facilities),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localization.hotel_details_facilities_list_title,
          style: AppTextStyles.headlineMedium(
            context,
            color: context.colors.titleColor,
          ),
        ),
        backgroundColor: context.colors.gray0,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<FacilitiesListBloc, FacilitiesListState>(
        builder: (context, state) {
          return ListView.separated(
            padding: EdgeInsets.all(context.scaleValue(16)),
            itemCount: state.facilities.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: context.scaleValue(12)),
            itemBuilder: (context, index) {
              final facility = state.facilities[index];
              final isExpanded = state.expandedIndices.contains(index);
              return FacilityExpansionTile(
                facility: facility,
                isExpanded: isExpanded,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}
