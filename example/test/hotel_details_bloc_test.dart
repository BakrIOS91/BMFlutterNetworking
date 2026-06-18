import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

class MockHotelClient extends Mock implements HotelClient {}

void main() {
  group('HotelDetailsBloc', () {
    late MockAppPreferences mockPrefs;
    late MockHotelClient mockClient;
    late Hotel mockHotel;

    setUp(() {
      mockPrefs = MockAppPreferences();
      mockClient = MockHotelClient();
      mockHotel = Hotel(
        id: 1,
        title: 'Test Hotel',
        isFavorite: false,
        location: Location(lat: 30.0, lon: 31.0),
      );
    });

    HotelDetailsBloc buildBloc() =>
        HotelDetailsBloc(mockHotel, mockPrefs, mockClient);

    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.hotel, equals(mockHotel));
      expect(bloc.state.isCollapsed, isFalse);
      expect(bloc.state.isDescriptionExpanded, isFalse);
      expect(bloc.state.pinAddress, isNull);
      expect(bloc.state.navigationTo, isNull);
      expect(bloc.state.viewState, equals(ViewState.loaded));
      bloc.close();
    });

    blocTest<HotelDetailsBloc, HotelDetailsState>(
      'emits state with isCollapsed=true when sheet size >= 0.95',
      build: buildBloc,
      act: (bloc) => bloc.add(const HotelDetailsEvent.sheetSizeChanged(0.95)),
      expect: () => [
        HotelDetailsState.initial(mockHotel).copyWith(isCollapsed: true),
      ],
    );

    blocTest<HotelDetailsBloc, HotelDetailsState>(
      'emits state with isCollapsed=false when sheet size < 0.95',
      build: buildBloc,
      seed: () =>
          HotelDetailsState.initial(mockHotel).copyWith(isCollapsed: true),
      act: (bloc) => bloc.add(const HotelDetailsEvent.sheetSizeChanged(0.80)),
      expect: () => [
        HotelDetailsState.initial(mockHotel).copyWith(isCollapsed: false),
      ],
    );

    blocTest<HotelDetailsBloc, HotelDetailsState>(
      'emits state with toggled description expanded',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const HotelDetailsEvent.didPressOnToggleDescription()),
      expect: () => [
        HotelDetailsState.initial(mockHotel)
            .copyWith(isDescriptionExpanded: true),
      ],
    );

    blocTest<HotelDetailsBloc, HotelDetailsState>(
      'emits state with navigationTo=facilities when see all facilities pressed',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const HotelDetailsEvent.didPressOnSeeAllFacilities()),
      expect: () => [
        HotelDetailsState.initial(mockHotel)
            .copyWith(navigationTo: NavigationType.facilities),
      ],
    );

    blocTest<HotelDetailsBloc, HotelDetailsState>(
      'emits state with null navigationTo on resetNavigation',
      build: buildBloc,
      seed: () => HotelDetailsState.initial(mockHotel)
          .copyWith(navigationTo: NavigationType.facilities),
      act: (bloc) => bloc.add(const HotelDetailsEvent.resetNavigation()),
      expect: () => [
        HotelDetailsState.initial(mockHotel).copyWith(navigationTo: null),
      ],
    );

    group('ToggleFavorite', () {
      blocTest<HotelDetailsBloc, HotelDetailsState>(
        'navigates to login if user is not logged in',
        setUp: () {
          when(() => mockPrefs.loggedIn).thenReturn(false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const HotelDetailsEvent.toggleFavorite()),
        expect: () => [
          HotelDetailsState.initial(mockHotel)
              .copyWith(navigationTo: NavigationType.login),
        ],
        verify: (_) {
          verifyNever(() => mockClient.toggleFavoriteHotel(any()));
        },
      );

      blocTest<HotelDetailsBloc, HotelDetailsState>(
        'emits loading and then loaded state with toggled favorite on success',
        setUp: () {
          when(() => mockPrefs.loggedIn).thenReturn(true);
          when(() => mockClient.toggleFavoriteHotel(any()))
              .thenAnswer((_) async => Success<void, APIError>(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const HotelDetailsEvent.toggleFavorite()),
        expect: () => [
          isA<HotelDetailsState>()
              .having((s) => s.viewState, 'viewState', ViewState.loading),
          isA<HotelDetailsState>()
              .having((s) => s.viewState, 'viewState', ViewState.loaded)
              .having((s) => s.hotel.isFavorite, 'isFavorite', true),
        ],
        verify: (_) {
          verify(() => mockClient.toggleFavoriteHotel('1')).called(1);
        },
      );
    });
  });
}
