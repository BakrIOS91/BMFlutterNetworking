import "package:flutter_example/core/storage_services/hive_box_name.dart";
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/core/storage_services/hive_storage_client.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:flutter_example/features/tab/childs/booking/bloc/booking_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/core.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_example/core/preferences/app_preferences.dart';

class MockHiveStorageClient extends Mock implements HiveStorageClient {}
class MockAppPreferences extends Mock implements AppPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(
        (Map<String, dynamic> json) => BookingModel.fromJson(json));
    registerFallbackValue(HiveBoxName.hotelBookings);
  });

  group('BookingBloc', () {
    late HiveStorageClient mockStorage;
    late AppPreferences mockAppPreferences;
    late BookingModel mockBooking1;
    late BookingModel mockBooking2;
    late List<BookingModel> mockBookings;

    setUp(() {
      mockStorage = MockHiveStorageClient();
      mockAppPreferences = MockAppPreferences();

      mockBooking1 = BookingModel(
        id: '1',
        hotel: Hotel(id: 1, title: 'Red Sea Villa'),
        totalNightsPrice: 150,
        cleaningFee: 10,
        serviceFee: 5,
        checkIn: DateTime(2026, 4, 6),
        checkOut: DateTime(2026, 4, 7),
        guestCount: 2,
      );

      mockBooking2 = BookingModel(
        id: '2',
        hotel: Hotel(id: 2, title: 'Hurghada Coral Resort'),
        totalNightsPrice: 200,
        cleaningFee: 10,
        serviceFee: 5,
        checkIn: DateTime(2026, 4, 6),
        checkOut: DateTime(2026, 4, 7),
        guestCount: 2,
      );

      mockBookings = [mockBooking1, mockBooking2];
    });

    BookingBloc buildBloc() => BookingBloc(mockAppPreferences, mockStorage);

    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.bookings, isEmpty);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.resultsViewState, equals(ViewState.loading));
      bloc.close();
    });

    group('Event: started', () {
      blocTest<BookingBloc, BookingState>(
        'emits loading then loaded with data when storage has items',
        build: () {
          when(() => mockAppPreferences.loggedIn).thenReturn(true);
          when(() => mockStorage.fetchAll<BookingModel>(
                box: any(named: 'box'),
                fromJson: any(named: 'fromJson'),
              )).thenAnswer((_) async => mockBookings);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const BookingEvent.started()),
        expect: () => [
          isA<BookingState>()
              .having((s) => s.resultsViewState, 'resultsViewState',
                  ViewState.loading),
          isA<BookingState>()
              .having(
                  (s) => s.resultsViewState, 'resultsViewState', ViewState.loaded)
              .having((s) => s.bookings, 'bookings', mockBookings),
        ],
        verify: (_) {
          verify(() => mockStorage.fetchAll<BookingModel>(
                box: HiveBoxName.hotelBookings,
                fromJson: BookingModel.fromJson, // Matches exactly
              )).called(1);
        },
      );

      blocTest<BookingBloc, BookingState>(
        'emits loading then NoData when storage is empty',
        build: () {
          when(() => mockAppPreferences.loggedIn).thenReturn(true);
          when(() => mockStorage.fetchAll<BookingModel>(
                box: any(named: 'box'),
                fromJson: BookingModel.fromJson,
              )).thenAnswer((_) async => []);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const BookingEvent.started()),
        expect: () => [
          isA<BookingState>()
              .having((s) => s.resultsViewState, 'resultsViewState',
                  ViewState.loading),
          isA<BookingState>()
              .having(
                  (s) => s.resultsViewState, 'resultsViewState', isA<NoData>())
              .having((s) => s.bookings, 'bookings', isEmpty),
        ],
      );
    });

    group('Event: queryChanged', () {
      blocTest<BookingBloc, BookingState>(
        'updates searchQuery in state',
        build: buildBloc,
        act: (bloc) => bloc.add(const BookingEvent.queryChanged('red')),
        expect: () => [
          isA<BookingState>().having((s) => s.searchQuery, 'searchQuery', 'red'),
        ],
      );
    });

    group('Event: clearSearch', () {
      blocTest<BookingBloc, BookingState>(
        'clears searchQuery in state',
        build: buildBloc,
        seed: () => const BookingState.initial(searchQuery: 'coral'),
        act: (bloc) => bloc.add(const BookingEvent.clearSearch()),
        expect: () => [
          isA<BookingState>().having((s) => s.searchQuery, 'searchQuery', ''),
        ],
      );
    });

    group('Event: deleteBooking', () {
      blocTest<BookingBloc, BookingState>(
        'removes booking from state and storage when deletion is successful',
        build: () {
          when(() => mockStorage.deleteWhere<BookingModel>(
                box: any(named: 'box'),
                fromJson: any(named: 'fromJson'),
                predicate: any(named: 'predicate'),
              )).thenAnswer((_) async => true);
          return buildBloc();
        },
        seed: () => BookingState.initial(
          bookings: mockBookings,
          viewState: ViewState.loaded,
        ),
        act: (bloc) => bloc.add(BookingEvent.deleteBooking(mockBooking1)),
        expect: () => [
          isA<BookingState>()
              .having((s) => s.bookings, 'bookings', [mockBooking2])
              .having((s) => s.resultsViewState, 'resultsViewState',
                  ViewState.loaded),
        ],
        verify: (_) {
          verify(() => mockStorage.deleteWhere<BookingModel>(
                box: HiveBoxName.hotelBookings,
                fromJson: BookingModel.fromJson,
                predicate: any(named: 'predicate'),
              )).called(1);
        },
      );

      blocTest<BookingBloc, BookingState>(
        'does not emit new state when deletion fails',
        build: () {
          when(() => mockStorage.deleteWhere<BookingModel>(
                box: any(named: 'box'),
                fromJson: any(named: 'fromJson'),
                predicate: any(named: 'predicate'),
              )).thenAnswer((_) async => false);
          return buildBloc();
        },
        seed: () => BookingState.initial(
          bookings: mockBookings,
          viewState: ViewState.loaded,
        ),
        act: (bloc) => bloc.add(BookingEvent.deleteBooking(mockBooking1)),
        expect: () => [],
      );
    });

    group('filteredBookings (Computed Property)', () {
      test('returns all bookings when searchQuery is empty', () {
        final state = BookingState.initial(
          bookings: mockBookings,
          searchQuery: '',
          viewState: ViewState.loaded,
        );
        expect(state.filteredBookings, equals(mockBookings));
      });

      test('returns filtered bookings matching case-insensitive title', () {
        final state = BookingState.initial(
          bookings: mockBookings,
          searchQuery: 'RED',
          viewState: ViewState.loaded,
        );
        
        expect(state.filteredBookings, hasLength(1));
        expect(state.filteredBookings.first.hotel.title, 'Red Sea Villa');
      });

      test('returns empty list when no match is found', () {
        final state = BookingState.initial(
          bookings: mockBookings,
          searchQuery: 'nonexistent',
          viewState: ViewState.loaded,
        );
        
        expect(state.filteredBookings, isEmpty);
      });
    });
  });
}
