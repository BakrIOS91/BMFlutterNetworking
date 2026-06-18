part of 'splash_bloc.dart';

@freezed
class SplashEvent with _$SplashEvent {
  const factory SplashEvent.started() = _Started;
  const factory SplashEvent.checkJailBreak() = _CheckJailBreak;
  const factory SplashEvent.jailbreakResponse(SecurityCheckResult result) =
      _JailbreakResponse;
  const factory SplashEvent.fetchLookups() = _FetchLookups;
  const factory SplashEvent.lookupResponse(Result<Lookup?, APIError> result) =
      _LookupResponse;
}
