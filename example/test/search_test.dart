import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/features/tab/childs/home/childs/search/bloc/search_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart'
    as lookups;
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

class MockHotelClient extends Mock implements HotelClient {}

void main() {
  late MockAppPreferences mockPrefs;
  late MockHotelClient mockHotelClient;
  late SearchBloc searchBloc;

  setUpAll(() {
    registerFallbackValue(const SearchEvent.started());
    registerFallbackValue(const SearchEvent.queryChanged(''));
    registerFallbackValue(const FilterHotelsRequest());
  });

  setUp(() {
    mockPrefs = MockAppPreferences();
    mockHotelClient = MockHotelClient();

    // Default stubs
    when(() => mockPrefs.currentLanguage).thenReturn('en');
    when(() => mockPrefs.lookups).thenReturn(lookups.Lookup(
      hotelCategories: [
        lookups.Category(id: 0, title: 'All'),
        lookups.Category(id: 1, title: 'Hotels'),
      ],
    ));

    when(() => mockPrefs.loggedIn).thenReturn(false);
    searchBloc = SearchBloc(mockHotelClient, mockPrefs);
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    test('initial state is correct', () {
      expect(searchBloc.state, SearchState.initial());
    });

    blocTest<SearchBloc, SearchState>(
      'started event triggers initial search',
      build: () {
        when(() => mockHotelClient.filterHotels(
              any(),
            )).thenAnswer((_) async => Success(Hotels(hotels: [])));
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchEvent.started()),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.viewState.toString(), 'viewState', contains('Loaded')),
        isA<SearchState>()
            .having((s) => s.viewState.toString(), 'viewState', contains('Loading')),
        isA<SearchState>()
            .having((s) => s.viewState.toString(), 'viewState', contains('NoData')),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'requestSearch emits loading when current results are empty',
      build: () {
        when(() => mockHotelClient.filterHotels(
                  any(),
                ))
            .thenAnswer((_) async =>
                Success(Hotels(hotels: [Hotel(id: 1, title: 'Hotel 1')])));
        return searchBloc;
      },
      act: (bloc) {
        bloc.add(const SearchEvent.queryChanged('query'));
        bloc.add(const SearchEvent.requestSearch());
      },
      expect: () => [
        isA<SearchState>().having((s) => s.query, 'query', 'query'),
        isA<SearchState>()
            .having((s) => s.viewState.toString(), 'viewState', contains('Loading'))
            .having((s) => s.query, 'query', 'query'),
        isA<SearchState>()
            .having((s) => s.viewState.toString(), 'viewState', contains('Loaded'))
            .having((s) => s.searchResults.length, 'results count', 1),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'requestSearch avoids loading flicker when results already exist',
      seed: () => SearchState(
        searchResults: [Hotel(id: 1, title: 'Old Hotel')],
        viewState: ViewState.loaded,
      ),
      build: () {
        when(() => mockHotelClient.filterHotels(
                  any(),
                ))
            .thenAnswer((_) async =>
                Success(Hotels(hotels: [Hotel(id: 2, title: 'New Hotel')])));
        return searchBloc;
      },
      act: (bloc) {
        bloc.add(const SearchEvent.queryChanged('new query'));
        bloc.add(const SearchEvent.requestSearch());
      },
      expect: () => [
        isA<SearchState>().having((s) => s.query, 'query', 'new query'),
        isA<SearchState>()
            .having((s) => s.viewState.toString(), 'viewState', contains('Loading'))
            .having((s) => s.query, 'query', 'new query'),
        isA<SearchState>().having(
            (s) => s.searchResults[0].title, 'first result', 'New Hotel'),
      ],
    );
  });
}
