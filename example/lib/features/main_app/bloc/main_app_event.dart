part of 'main_app_bloc.dart';

@freezed
class MainAppEvent with _$MainAppEvent {
  const factory MainAppEvent.started() = _Started;
}
