import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart'
    as lookups;
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';

part 'filter_event.dart';

part 'filter_state.dart';

part 'filter_bloc.freezed.dart';

@injectable
class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final AppPreferences pref;

  FilterBloc(
    this.pref,
    @factoryParam FilterHotelsRequest? initialRequest,
  ) : super(
          FilterState.fromLookups(
            pref.lookups,
            initialRequest: initialRequest,
            lang: pref.currentLanguage,
          ),
        ) {
    on<CategoryChanged>(_onCategoryChanged);
    on<PriceChanged>(_onPriceChanged);
    on<InstantBookToggled>(_onInstantBookToggled);
    on<LocationSelected>(_onLocationSelected);
    on<FacilityToggled>(_onFacilityToggled);
    on<RatingSelected>(_onRatingSelected);
  }

  void _onCategoryChanged(CategoryChanged event, Emitter<FilterState> emit) {
    emit(state.copyWith(
        selection: state.selection.copyWith(catId: event.categoryId)));
  }

  void _onPriceChanged(PriceChanged event, Emitter<FilterState> emit) {
    emit(state.copyWith(
        selection: state.selection.copyWith(
            minPrice: event.min.toInt(), maxPrice: event.max.toInt())));
  }

  void _onInstantBookToggled(
    InstantBookToggled event,
    Emitter<FilterState> emit,
  ) {
    emit(state.copyWith(
        selection: state.selection
            .copyWith(pInstantBook: !state.selection.pInstantBook)));
  }

  void _onLocationSelected(LocationSelected event, Emitter<FilterState> emit) {
    final newLocation =
        state.selection.cityName == event.location ? null : event.location;
    emit(state.copyWith(
        selection: state.selection.copyWith(cityName: newLocation)));
  }

  void _onFacilityToggled(FacilityToggled event, Emitter<FilterState> emit) {
    final currentIds = List<int>.from(state.selection.facilitiesIds);
    if (currentIds.contains(event.facilityId)) {
      currentIds.remove(event.facilityId);
    } else {
      currentIds.add(event.facilityId);
    }
    emit(state.copyWith(
        selection: state.selection.copyWith(facilitiesIds: currentIds)));
  }

  void _onRatingSelected(RatingSelected event, Emitter<FilterState> emit) {
    final newRating =
        state.selection.minRating == event.rating ? null : event.rating;
    emit(state.copyWith(
        selection: state.selection.copyWith(minRating: newRating)));
  }
}
