part of 'checkout_bloc.dart';

@freezed
abstract class CheckoutState with _$CheckoutState {
  const CheckoutState._();
  const factory CheckoutState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(false) bool success,
  }) = _CheckoutState;

  factory CheckoutState.initial() => const CheckoutState();
}
