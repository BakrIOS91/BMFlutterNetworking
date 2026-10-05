import "package:flutter_example/core/storage_services/hive_box_name.dart";
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/bloc/hotel_booking_bloc.dart';
import 'package:flutter_example/core/storage_services/hive_storage_client.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';

class MockHiveStorageClient extends Mock implements HiveStorageClient {}

class FakeBookingModel extends Fake implements BookingModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBookingModel());
    registerFallbackValue(HiveBoxName.hotelBookings);
  });

  group('HotelBookingBloc', () {
    late Hotel mockHotel;
    late HiveStorageClient mockStorage;

    setUp(() {
      mockHotel = Hotel(
        id: 1,
        title: 'Test Hotel',
        pricePerNight: 100,
        rate: 4.5,
        location: Location(lat: 30.0, lon: 31.0),
      );
      mockStorage = MockHiveStorageClient();

      when(() => mockStorage.add<BookingModel>(
            box: any(named: 'box'),
            item: any(named: 'item'),
            toJson: any(named: 'toJson'),
          )).thenAnswer((_) async {});
    });

    HotelBookingBloc buildBloc() => HotelBookingBloc(mockHotel);

    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.hotel, equals(mockHotel));
      expect(bloc.state.checkIn, isNotNull);
      expect(bloc.state.checkOut, isNotNull);
      expect(bloc.state.guestCount, equals(1));
      expect(bloc.state.nightCount, equals(1));
      expect(bloc.state.paymentDetails, isNull);
      bloc.close();
    });

    blocTest<HotelBookingBloc, HotelBookingState>(
      'started event calculates initial payment details',
      build: buildBloc,
      act: (bloc) => bloc.add(const HotelBookingEvent.started()),
      expect: () => [
        isA<HotelBookingState>()
            .having((s) => s.paymentDetails, 'paymentDetails', isNotNull)
            .having((s) => s.nightCount, 'nightCount', 1)
      ],
    );

    group('Date Selection', () {
      final checkInDate = DateTime(2024, 4, 10);
      final checkOutDate = DateTime(2024, 4, 12);

      blocTest<HotelBookingBloc, HotelBookingState>(
        'updates checkIn normally when before checkOut',
        build: buildBloc,
        seed: () => HotelBookingState.initial(mockHotel).copyWith(
          checkIn: DateTime(2024, 4, 1),
          checkOut: DateTime(2024, 4, 15),
        ),
        act: (bloc) => bloc.add(HotelBookingEvent.checkInSelected(checkInDate)),
        expect: () => [
          isA<HotelBookingState>()
              .having((s) => s.checkIn, 'checkIn', checkInDate)
              .having((s) => s.checkOut, 'checkOut', DateTime(2024, 4, 15)),
          isA<HotelBookingState>()
              .having((s) => s.checkIn, 'checkIn', checkInDate)
              .having((s) => s.checkOut, 'checkOut', DateTime(2024, 4, 15))
              .having((s) => s.nightCount, 'nightCount', 5)
              .having((s) => s.paymentDetails, 'paymentDetails', isNotNull),
        ],
      );

      blocTest<HotelBookingBloc, HotelBookingState>(
        'updates checkOut state and recalculates payment when checkOutSelected',
        build: buildBloc,
        seed: () => HotelBookingState.initial(mockHotel).copyWith(
          checkIn: DateTime(2024, 4, 10),
          checkOut: DateTime(2024, 4, 11),
        ),
        act: (bloc) =>
            bloc.add(HotelBookingEvent.checkOutSelected(checkOutDate)),
        expect: () => [
          isA<HotelBookingState>()
              .having((s) => s.checkOut, 'checkOut', checkOutDate),
          isA<HotelBookingState>()
              .having((s) => s.checkOut, 'checkOut', checkOutDate)
              .having((s) => s.nightCount, 'nightCount', 2)
              .having((s) => s.paymentDetails, 'paymentDetails', isNotNull),
        ],
      );

      blocTest<HotelBookingBloc, HotelBookingState>(
        'adjusts checkOut when checkIn is moved past it',
        build: buildBloc,
        seed: () => HotelBookingState.initial(mockHotel).copyWith(
          checkIn: DateTime(2024, 1, 1),
          checkOut: DateTime(2024, 1, 2),
        ),
        act: (bloc) =>
            bloc.add(HotelBookingEvent.checkInSelected(DateTime(2024, 1, 5))),
        expect: () => [
          isA<HotelBookingState>()
              .having((s) => s.checkIn, 'checkIn', DateTime(2024, 1, 5))
              .having((s) => s.checkOut, 'checkOut', DateTime(2024, 1, 6)),
          isA<HotelBookingState>()
              .having((s) => s.checkIn, 'checkIn', DateTime(2024, 1, 5))
              .having((s) => s.checkOut, 'checkOut', DateTime(2024, 1, 6))
              .having((s) => s.nightCount, 'nightCount', 1)
              .having((s) => s.paymentDetails, 'paymentDetails', isNotNull),
        ],
      );
    });

    group('Guest Counter', () {
      blocTest<HotelBookingBloc, HotelBookingState>(
        'increments guestCount',
        build: buildBloc,
        seed: () => HotelBookingState.initial(mockHotel).copyWith(
          checkIn: DateTime(2024, 4, 10),
          checkOut: DateTime(2024, 4, 12),
        ),
        act: (bloc) => bloc.add(const HotelBookingEvent.guestIncremented()),
        expect: () => [
          isA<HotelBookingState>().having((s) => s.guestCount, 'guestCount', 2),
          isA<HotelBookingState>()
              .having((s) => s.guestCount, 'guestCount', 2)
              .having((s) => s.paymentDetails, 'paymentDetails', isNotNull),
        ],
      );

      blocTest<HotelBookingBloc, HotelBookingState>(
        'decrements guestCount',
        build: buildBloc,
        seed: () => HotelBookingState.initial(mockHotel).copyWith(
            checkIn: DateTime(2024, 4, 10),
            checkOut: DateTime(2024, 4, 12),
            guestCount: 2),
        act: (bloc) => bloc.add(const HotelBookingEvent.guestDecremented()),
        expect: () => [
          isA<HotelBookingState>().having((s) => s.guestCount, 'guestCount', 1),
          isA<HotelBookingState>()
              .having((s) => s.guestCount, 'guestCount', 1)
              .having((s) => s.paymentDetails, 'paymentDetails', isNotNull),
        ],
      );

      blocTest<HotelBookingBloc, HotelBookingState>(
        'does not decrement below 1',
        build: buildBloc,
        act: (bloc) => bloc.add(const HotelBookingEvent.guestDecremented()),
        expect: () => [],
      );

      blocTest<HotelBookingBloc, HotelBookingState>(
        'does not increment above _kMaxGuests (10)',
        build: buildBloc,
        seed: () =>
            HotelBookingState.initial(mockHotel).copyWith(guestCount: 10),
        act: (bloc) => bloc.add(const HotelBookingEvent.guestIncremented()),
        expect: () => [],
      );
    });



    group('BookingModel Serialization', () {
      test('toJson and fromJson round-trip successfully', () {
        final payment = BookingModel(
          id: '1',
          hotel: mockHotel,
          totalNightsPrice: 100.0,
          cleaningFee: 10.0,
          serviceFee: 5.0,
          checkIn: DateTime(2026, 1, 1),
          checkOut: DateTime(2026, 1, 2),
          guestCount: 1,
        );

        final json = payment.toJson();
        final decoded = BookingModel.fromJson(json);

        expect(decoded.hotel.id, mockHotel.id);
        expect(decoded.hotel.title, mockHotel.title);
        expect(decoded.totalNightsPrice, 100.0);
        expect(decoded.cleaningFee, 10.0);
        expect(decoded.serviceFee, 5.0);
        expect(decoded.checkIn, DateTime(2026, 1, 1));
        expect(decoded.checkOut, DateTime(2026, 1, 2));
        expect(decoded.guestCount, 1);
      });
    });

    group('Calculation Deep Testing', () {
      test('calculates correct payment for multiple nights and guests',
          () async {
        final bloc = buildBloc();
        final checkIn = DateTime(2024, 1, 1);
        final checkOut = DateTime(2024, 1, 4); // 3 nights

        bloc.add(HotelBookingEvent.checkInSelected(checkIn));
        bloc.add(HotelBookingEvent.checkOutSelected(checkOut));
        bloc.add(const HotelBookingEvent.guestIncremented()); // 2 guests

        // 3 nights * $100 * 2 guests = $600
        // cleaning fee = 600 * 0.0125 = 7.5
        // service fee  = 600 * 0.0125 = 7.5
        // total        = 600 + 7.5 + 7.5 = 615.0

        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<HotelBookingState>()
                .having((s) => s.nightCount, 'nightCount', 3)
                .having((s) => s.guestCount, 'guestCount', 2)
                .having((s) => s.paymentDetails?.totalNightsPrice, 'subtotal',
                    600.0)
                .having((s) => s.paymentDetails?.cleaningFee, 'cleaning', 7.5)
                .having((s) => s.paymentDetails?.serviceFee, 'service', 7.5),
          ),
        );
        bloc.close();
      });

      test('counts same-day booking as 1 night', () async {
        final bloc = buildBloc();
        final sameDay = DateTime(2024, 1, 1);

        bloc.add(HotelBookingEvent.checkInSelected(sameDay));
        bloc.add(HotelBookingEvent.checkOutSelected(sameDay));

        // same-day → diff = 0 → clamped to 1 night
        // 1 night * $100 * 1 guest = $100
        // cleaning = $1.25, service = $1.25, total = $102.5

        await expectLater(
          bloc.stream,
          emitsThrough(isA<HotelBookingState>()
              .having((s) => s.nightCount, 'nightCount', 1)),
        );
        bloc.close();
      });

      test('payment is zero before any dates are selected', () {
        final bloc = buildBloc();
        expect(bloc.state.paymentDetails, isNull);
        bloc.close();
      });
    });
  });
}
