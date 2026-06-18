part of 'filter_bloc.dart';

@freezed
class FilterEvent with _$FilterEvent {
  const factory FilterEvent.categoryChanged(int categoryId) = CategoryChanged;

  const factory FilterEvent.priceChanged(double min, double max) = PriceChanged;

  const factory FilterEvent.instantBookToggled() = InstantBookToggled;

  const factory FilterEvent.locationSelected(String location) =
      LocationSelected;

  const factory FilterEvent.facilityToggled(int facilityId) = FacilityToggled;

  const factory FilterEvent.ratingSelected(int rating) = RatingSelected;
}
