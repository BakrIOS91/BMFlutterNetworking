part of 'checkout_bloc.dart';

@freezed
class CheckoutEvent with _$CheckoutEvent {
  const factory CheckoutEvent.started() = _Started;
  const factory CheckoutEvent.confirmPressed() = _ConfirmPressed;
  const factory CheckoutEvent.cancelPressed() = _CancelPressed;
}
