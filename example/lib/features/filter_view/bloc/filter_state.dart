part of 'filter_bloc.dart';

@freezed
abstract class FilterState with _$FilterState {
  const factory FilterState({
    required FilterHotelsRequest selection,
    @Default([]) List<lookups.Category> categories,
    @Default([]) List<lookups.City> cities,
    @Default([]) List<lookups.Category> facilities,
  }) = _FilterState;

  factory FilterState.initial() => const FilterState(
        selection: FilterHotelsRequest(),
      );

  factory FilterState.fromLookups(lookups.Lookup? lookup,
      {FilterHotelsRequest? initialRequest, required String lang}) {
    if (lookup == null) return FilterState.initial();
    final categories = lookup.hotelCategories ?? [];
    final defaultCatId = categories.isNotEmpty ? categories.first.id : null;

    final selection = initialRequest != null
        ? initialRequest.copyWith(
            catId: initialRequest.catId ?? defaultCatId, lang: lang)
        : FilterHotelsRequest(catId: defaultCatId, lang: lang);

    return FilterState(
      categories: categories,
      cities: lookup.cities ?? [],
      facilities: lookup.facilitiesCategories ?? [],
      selection: selection,
    );
  }
}
