import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/storage_services/hive_storage.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';

part 'checkout_bloc.freezed.dart';
part 'checkout_event.dart';
part 'checkout_state.dart';

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final BookingModel booking;
  final HiveStorageClient _storage;

  CheckoutBloc(@factoryParam this.booking, this._storage)
      : super(CheckoutState.initial()) {
    on<_Started>(_onStarted);
    on<_ConfirmPressed>(_onConfirmPressed);
  }

  void _onStarted(_Started event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(viewState: ViewState.loaded));
  }

  Future<void> _onConfirmPressed(
      _ConfirmPressed event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(viewState: ViewState.loading));

    try {
      await _storage.add<BookingModel>(
        box: HiveBoxName.hotelBookings,
        item: booking,
        toJson: (b) => b.toJson(),
      );

      emit(state.copyWith(
        viewState: ViewState.loaded,
        success: true,
      ));
    } catch (e) {
      emit(state.copyWith(viewState: const UnexpectedError()));
    }
  }
}
