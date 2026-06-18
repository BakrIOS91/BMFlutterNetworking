import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:uuid/uuid.dart';

class BookingModel {
  final String id;
  final Hotel hotel;
  final double totalNightsPrice;
  final double cleaningFee;
  final double serviceFee;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guestCount;

  BookingModel({
    required this.id,
    required this.hotel,
    required this.totalNightsPrice,
    required this.cleaningFee,
    required this.serviceFee,
    this.checkIn,
    this.checkOut,
    this.guestCount,
  });

  double get totalPayment => totalNightsPrice + cleaningFee + serviceFee;

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] ?? const Uuid().v4(),
        hotel: Hotel.fromJson(json['hotel']),
        totalNightsPrice: (json['total_nights_price'] ?? 0).toDouble(),
        cleaningFee: (json['cleaning_fee'] ?? 0).toDouble(),
        serviceFee: (json['service_fee'] ?? 0).toDouble(),
        checkIn:
            json['check_in'] != null ? DateTime.parse(json['check_in']) : null,
        checkOut: json['check_out'] != null
            ? DateTime.parse(json['check_out'])
            : null,
        guestCount: json['guest_count'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hotel': hotel.toJson(),
        'total_nights_price': totalNightsPrice,
        'cleaning_fee': cleaningFee,
        'service_fee': serviceFee,
        'check_in': checkIn?.toIso8601String(),
        'check_out': checkOut?.toIso8601String(),
        'guest_count': guestCount,
      };

  String formattedPrice(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
