enum HiveBoxName {
  hotelBookings('hotel_bookings_box'),
  // Add more boxes here as the app grows
  ;

  const HiveBoxName(this.value);
  final String value;
}
