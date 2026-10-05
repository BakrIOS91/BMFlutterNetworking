import "package:flutter_example/core/storage_services/hive_box_name.dart";
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/core/storage_services/hive_storage_client.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/childs/checkout/bloc/checkout_bloc.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/core.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveStorageClient extends Mock implements HiveStorageClient {}

class FakeBookingModel extends Fake implements BookingModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBookingModel());
    registerFallbackValue(HiveBoxName.hotelBookings);
  });

  group('CheckoutBloc', () {
    late HiveStorageClient mockStorage;
    late BookingModel mockBooking;

    setUp(() {
      mockStorage = MockHiveStorageClient();
      mockBooking = BookingModel(
        id: '1',
        hotel: Hotel(id: 1, title: 'Test Hotel', pricePerNight: 100),
        totalNightsPrice: 200,
        cleaningFee: 2.5,
        serviceFee: 2.5,
        checkIn: DateTime(2026, 4, 10),
        checkOut: DateTime(2026, 4, 12),
        guestCount: 1,
      );
    });

    CheckoutBloc buildBloc() =>
        CheckoutBloc(mockBooking, mockStorage);

    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.viewState, equals(ViewState.loaded));
      expect(bloc.state.success, isFalse);
      expect(bloc.booking, equals(mockBooking));
      bloc.close();
    });

    group('Event: started', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'emits loaded state',
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckoutEvent.started()),
        expect: () => [
          isA<CheckoutState>()
              .having((s) => s.viewState, 'viewState', ViewState.loaded),
        ],
      );
    });

    group('Event: confirmPressed', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'emits loading then success when storage succeeds',
        build: () {
          when(() => mockStorage.add<BookingModel>(
                box: any(named: 'box'),
                item: any(named: 'item'),
                toJson: any(named: 'toJson'),
              )).thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CheckoutEvent.confirmPressed()),
        expect: () => [
          isA<CheckoutState>()
              .having((s) => s.viewState, 'viewState', ViewState.loading),
          isA<CheckoutState>()
              .having((s) => s.viewState, 'viewState', ViewState.loaded)
              .having((s) => s.success, 'success', isTrue),
        ],
        verify: (_) {
          verify(() => mockStorage.add<BookingModel>(
                box: HiveBoxName.hotelBookings,
                item: mockBooking,
                toJson: any(named: 'toJson'),
              )).called(1);
        },
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'emits loading then error when storage throws',
        build: () {
          when(() => mockStorage.add<BookingModel>(
                box: any(named: 'box'),
                item: any(named: 'item'),
                toJson: any(named: 'toJson'),
              )).thenThrow(Exception('Hive write error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CheckoutEvent.confirmPressed()),
        expect: () => [
          isA<CheckoutState>()
              .having((s) => s.viewState, 'viewState', ViewState.loading),
          isA<CheckoutState>().having(
              (s) => s.viewState, 'viewState', isA<UnexpectedError>()),
        ],
      );
    });
  });
}
