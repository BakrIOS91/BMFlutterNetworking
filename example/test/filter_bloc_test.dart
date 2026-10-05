import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/filter_view/bloc/filter_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart'
    as lookups;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

void main() {
  late MockAppPreferences mockPrefs;
  late lookups.Lookup mockLookup;

  setUp(() {
    mockPrefs = MockAppPreferences();
    mockLookup = lookups.Lookup(
      hotelCategories: [
        lookups.Category(id: 1, title: 'Hotels'),
        lookups.Category(id: 2, title: 'Apartments'),
      ],
      cities: [
        lookups.City(id: 1, name: 'Cairo'),
        lookups.City(id: 2, name: 'Alex'),
      ],
      facilitiesCategories: [
        lookups.Category(id: 10, title: 'WiFi'),
        lookups.Category(id: 11, title: 'Pool'),
      ],
    );

    when(() => mockPrefs.lookups).thenReturn(mockLookup);
    when(() => mockPrefs.currentLanguage).thenReturn('en');
  });

  group('FilterBloc', () {
    test('initial state is correct from lookups', () {
      final bloc = FilterBloc(mockPrefs, null);
      expect(bloc.state.categories, equals(mockLookup.hotelCategories));
      expect(bloc.state.cities, equals(mockLookup.cities));
      expect(bloc.state.facilities, equals(mockLookup.facilitiesCategories));
      expect(bloc.state.selection.catId, equals(1)); // First category ID
      expect(bloc.state.selection.lang, equals('en'));
      bloc.close();
    });

    test('initial state is correct with initialRequest', () {
      const initialRequest = FilterHotelsRequest(catId: 2, cityName: 'Cairo');
      final bloc = FilterBloc(mockPrefs, initialRequest);
      expect(bloc.state.selection.catId, equals(2));
      expect(bloc.state.selection.cityName, equals('Cairo'));
      expect(bloc.state.selection.lang, equals('en'));
      bloc.close();
    });

    blocTest<FilterBloc, FilterState>(
      'emits updated catId when CategoryChanged is added',
      build: () => FilterBloc(mockPrefs, null),
      act: (bloc) => bloc.add(const FilterEvent.categoryChanged(2)),
      expect: () => [
        isA<FilterState>().having((s) => s.selection.catId, 'catId', 2),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits updated prices when PriceChanged is added',
      build: () => FilterBloc(mockPrefs, null),
      act: (bloc) => bloc.add(const FilterEvent.priceChanged(50, 150)),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.minPrice, 'minPrice', 50)
            .having((s) => s.selection.maxPrice, 'maxPrice', 150),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits toggled instant book when InstantBookToggled is added',
      build: () => FilterBloc(mockPrefs, null),
      act: (bloc) => bloc.add(const FilterEvent.instantBookToggled()),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.pInstantBook, 'pInstantBook', true),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits updated cityName when LocationSelected is added',
      build: () => FilterBloc(mockPrefs, null),
      act: (bloc) => bloc.add(const FilterEvent.locationSelected('Cairo')),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.cityName, 'cityName', 'Cairo'),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits null cityName when same LocationSelected is added (toggled off)',
      build: () => FilterBloc(mockPrefs, null),
      seed: () => FilterState.fromLookups(mockLookup,
          initialRequest: const FilterHotelsRequest(cityName: 'Cairo'),
          lang: 'en'),
      act: (bloc) => bloc.add(const FilterEvent.locationSelected('Cairo')),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.cityName, 'cityName', isNull),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits updated facilitiesIds when FacilityToggled is added',
      build: () => FilterBloc(mockPrefs, null),
      act: (bloc) => bloc.add(const FilterEvent.facilityToggled(10)),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.facilitiesIds, 'facilitiesIds', [10]),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'removes facilityId when FacilityToggled is added for existing facility',
      build: () => FilterBloc(mockPrefs, null),
      seed: () => FilterState.fromLookups(mockLookup,
          initialRequest: const FilterHotelsRequest(facilitiesIds: [10, 11]),
          lang: 'en'),
      act: (bloc) => bloc.add(const FilterEvent.facilityToggled(10)),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.facilitiesIds, 'facilitiesIds', [11]),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits updated minRating when RatingSelected is added',
      build: () => FilterBloc(mockPrefs, null),
      act: (bloc) => bloc.add(const FilterEvent.ratingSelected(4)),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.minRating, 'minRating', 4),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits null minRating when same RatingSelected is added (toggled off)',
      build: () => FilterBloc(mockPrefs, null),
      seed: () => FilterState.fromLookups(mockLookup,
          initialRequest: const FilterHotelsRequest(minRating: 4), lang: 'en'),
      act: (bloc) => bloc.add(const FilterEvent.ratingSelected(4)),
      expect: () => [
        isA<FilterState>()
            .having((s) => s.selection.minRating, 'minRating', isNull),
      ],
    );
  });
}
