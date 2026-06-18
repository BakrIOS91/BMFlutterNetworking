import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_example/utilities/helpers/validation_helper.dart';

part 'account_info_event.dart';
part 'account_info_state.dart';
part 'account_info_bloc.freezed.dart';

@Injectable()
class AccountInfoBloc extends Bloc<AccountInfoEvent, AccountInfoState> {
  final AppPreferences _pref;
  final AuthClient _authClient;

  AccountInfoBloc(
    this._pref,
    this._authClient,
  ) : super(AccountInfoState.initial()) {
    on<_Started>(_onStarted);
    on<_DidTapEdit>(_onDidTapEdit);
    on<_DidTapCancel>(_onDidTapCancel);
    on<_LoadData>(_onLoadData);
    on<_DidTapSave>(_onDidTapSave);
    on<_UpdateProfileResponse>(_onUpdateProfileResponse);
    on<_FirstNameChanged>(_onFirstNameChanged);
    on<_LastNameChanged>(_onLastNameChanged);
    on<_PhoneChanged>(_onPhoneChanged);
  }

  void _onFirstNameChanged(
      _FirstNameChanged event, Emitter<AccountInfoState> emit) {
    emit(state.copyWith(
      firstName: event.firstName,
      firstNameError: !_isValidName(event.firstName),
    ));
  }

  void _onLastNameChanged(
      _LastNameChanged event, Emitter<AccountInfoState> emit) {
    emit(state.copyWith(
      lastName: event.lastName,
      lastNameError: !_isValidName(event.lastName),
    ));
  }

  void _onPhoneChanged(_PhoneChanged event, Emitter<AccountInfoState> emit) {
    emit(state.copyWith(
      phone: event.phone,
      phoneError: !_isValidPhone(event.phone),
    ));
  }

  void _onStarted(_Started event, Emitter<AccountInfoState> emit) {
    add(const AccountInfoEvent.loadData());
  }

  void _onLoadData(_LoadData event, Emitter<AccountInfoState> emit) {
    emit(state.copyWith(viewState: ViewState.loading));
    final profile = _pref.userProfile;
    if (profile != null) {
      final fullName = profile.fullName ?? "";
      final nameParts = fullName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : "";
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

      emit(state.copyWith(
        viewState: ViewState.loaded,
        firstName: firstName,
        lastName: lastName,
        email: profile.email ?? "",
        phone: profile.phone ?? "",
        firstNameError: false,
        lastNameError: false,
        phoneError: false,
      ));
    } else {
      emit(state.copyWith(viewState: ViewState.unexpectedError));
    }
  }

  Future<void> _onDidTapSave(
      _DidTapSave event, Emitter<AccountInfoState> emit) async {
    final firstNameError = !_isValidName(state.firstName);
    final lastNameError = !_isValidName(state.lastName);
    final phoneError = !_isValidPhone(state.phone);

    if (firstNameError || lastNameError || phoneError) {
      emit(state.copyWith(
        firstName: state.firstName,
        lastName: state.lastName,
        phone: state.phone,
        firstNameError: firstNameError,
        lastNameError: lastNameError,
        phoneError: phoneError,
      ));
      return;
    }

    final fullName = "${state.firstName} ${state.lastName}".trim();

    emit(state.copyWith(
      viewState: ViewState.loading,
      firstName: state.firstName,
      lastName: state.lastName,
      phone: state.phone,
      firstNameError: false,
      lastNameError: false,
      phoneError: false,
    ));

    add(AccountInfoEvent.updateProfileResponse(
      await _authClient.updateProfile(
        UpdateProfileRequest(
          fullName: fullName,
          phone: state.phone,
        ),
      ),
    ));
  }

  void _onUpdateProfileResponse(
      _UpdateProfileResponse event, Emitter<AccountInfoState> emit) {
    event.result.when(
      success: (response) {
        if (response != null) {
          _pref.userProfile = response;

          final fullName = response.fullName ?? "";
          final nameParts = fullName.split(" ");
          final firstName = nameParts.isNotEmpty ? nameParts.first : "";
          final lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

          emit(state.copyWith(
            viewState: ViewState.loaded,
            isEditing: false,
            firstName: firstName,
            lastName: lastName,
            email: response.email ?? state.email,
            phone: response.phone ?? state.phone,
          ));
        } else {
          emit(state.copyWith(viewState: ViewState.unexpectedError));
        }
      },
      failure: (error) {
        emit(state.copyWith(viewState: WithViewState.failHandler(error)));
      },
    );
  }

  void _onDidTapEdit(_DidTapEdit event, Emitter<AccountInfoState> emit) {
    emit(state.copyWith(isEditing: true));
  }

  void _onDidTapCancel(_DidTapCancel event, Emitter<AccountInfoState> emit) {
    emit(state.copyWith(
      isEditing: false,
      firstNameError: false,
      lastNameError: false,
      phoneError: false,
    ));
    add(AccountInfoEvent.loadData());
  }

  bool _isValidPhone(String phone) {
    return ValidationHelper.isValidPhone(phone);
  }

  bool _isValidName(String name) {
    return ValidationHelper.isValidName(name);
  }
}
