import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'main_app_bloc.freezed.dart';
part 'main_app_event.dart';
part 'main_app_state.dart';

@injectable
class MainAppBloc extends Bloc<MainAppEvent, MainAppState> {
  late final AppLifecycleListener listener;
  final AppPreferences _prefs;

  MainAppBloc(this._prefs) : super(MainAppState.initial()) {
    on<MainAppEvent>(_onEvent);
    add(const MainAppEvent.started());

    listener = AppLifecycleListener(
      onResume: () {
        if (Platform.isIOS) {
          final systemLocale =
              WidgetsBinding.instance.platformDispatcher.locale;
          _prefs.currentLanguage = systemLocale.languageCode;
        }
      },
    );
  }

  Future<void> _onEvent(
    MainAppEvent event,
    Emitter<MainAppState> emit,
  ) async {
    await event.map(
      started: (_) async {
        if (Platform.isIOS) {
          final systemLocale =
              WidgetsBinding.instance.platformDispatcher.locale;
          _prefs.currentLanguage = systemLocale.languageCode;
        }
        emit(state.copyWith(mode: _prefs.theme));
      },
    );
  }

  @override
  Future<void> close() {
    listener.dispose();
    return super.close();
  }
}
