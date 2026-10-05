part of 'account_info_bloc.dart';

@freezed
abstract class AccountInfoState with _$AccountInfoState {
  const factory AccountInfoState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(false) bool isEditing,
    @Default("") String firstName,
    @Default("") String lastName,
    @Default("") String email,
    @Default("") String phone,
    @Default(false) bool firstNameError,
    @Default(false) bool lastNameError,
    @Default(false) bool phoneError,
  }) = _AccountInfoState;

  factory AccountInfoState.initial() => const AccountInfoState(
    viewState: ViewState.loaded,
    isEditing: false,
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    firstNameError: false,
    lastNameError: false,
    phoneError: false,
  );
}