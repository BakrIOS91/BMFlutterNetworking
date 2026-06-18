import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_example/core/storage_services/hive_storage.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:bm_flutter/core.dart';

part 'booking_event.dart';

part 'booking_state.dart';

part 'booking_bloc.freezed.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._appPreferences, this._storage)
      : super(BookingState.initial()) {
    on<_Started>(_onStarted);
    on<_QueryChanged>(_onQueryChanged);
    on<_ClearSearch>(_onClearSearch);
    on<_DeleteBooking>(_onDeleteBooking);
  }

  final AppPreferences _appPreferences;
  final HiveStorageClient _storage;

  Future<void> _onStarted(_Started event, Emitter<BookingState> emit) async {
    if (_appPreferences.loggedIn) {
      emit(state.copyWith(
          bookings: [],
          searchQuery: '',
          viewState: ViewState.loaded,
          resultsViewState: ViewState.loading));
      final bookings = await _storage.fetchAll<BookingModel>(
        box: HiveBoxName.hotelBookings,
        fromJson: BookingModel.fromJson,
      );
      emit(state.copyWith(
        bookings: bookings,
        resultsViewState:
            bookings.isEmpty ? ViewState.noData : ViewState.loaded,
      ));
    } else {
      emit(state.copyWith(
        bookings: [],
        searchQuery: '',
        resultsViewState: ViewState.loaded,
        viewState: ViewState.unauthorized,
      ));
    }
  }

  void _onQueryChanged(_QueryChanged event, Emitter<BookingState> emit) {
    final newState = state.copyWith(searchQuery: event.query);
    emit(newState.copyWith(
      resultsViewState:
          newState.filteredBookings.isEmpty ? ViewState.noData : ViewState.loaded,
    ));
  }

  void _onClearSearch(_ClearSearch event, Emitter<BookingState> emit) {
    emit(state.copyWith(
      searchQuery: '',
      resultsViewState:
          state.bookings.isEmpty ? ViewState.noData : ViewState.loaded,
    ));
  }

  Future<void> _onDeleteBooking(
      _DeleteBooking event, Emitter<BookingState> emit) async {
    final success = await _storage.deleteWhere<BookingModel>(
      box: HiveBoxName.hotelBookings,
      fromJson: BookingModel.fromJson,
      predicate: (booking) => booking.id == event.booking.id,
    );

    if (success) {
      final updatedBookings =
          state.bookings.where((b) => b.id != event.booking.id).toList();

      emit(state.copyWith(
        bookings: updatedBookings,
        resultsViewState:
            updatedBookings.isEmpty ? ViewState.noData : ViewState.loaded,
      ));
    }
  }
}
