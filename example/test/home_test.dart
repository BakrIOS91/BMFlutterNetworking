import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/features/tab/childs/home/bloc/home_bloc.dart';
import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/core/location_services/location_manager.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

class MockHomeClient extends Mock implements HotelClient {}

class MockAuthClient extends Mock implements AuthClient {}

class MockLocationManager extends Mock implements LocationManager {}

void main() {
  final getIt = GetIt.instance;

  late MockAppPreferences mockPrefs;
  late MockHomeClient mockHomeClient;
  late MockAuthClient mockAuthClient;
  late MockLocationManager mockLocationManager;

  setUpAll(() {
    registerFallbackValue(const FilterHotelsRequest());
    registerFallbackValue(const PopularHotelsRequest());
  });

  setUp(() {
    mockPrefs = MockAppPreferences();
    mockHomeClient = MockHomeClient();
    mockAuthClient = MockAuthClient();
    mockLocationManager = MockLocationManager();

    getIt.reset();

    getIt.registerSingleton<AppPreferences>(mockPrefs);
    getIt.registerSingleton<HotelClient>(mockHomeClient);
    getIt.registerSingleton<AuthClient>(mockAuthClient);
    getIt.registerSingleton<LocationManager>(mockLocationManager);

    // Default stubs
    when(() => mockPrefs.loggedIn).thenReturn(false);
    when(() => mockPrefs.currentLanguage).thenReturn('en');
    when(() => mockHomeClient.getPopularHotels(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => mockHomeClient.filterHotels(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => mockAuthClient.getProfile())
        .thenAnswer((_) async => const Success(null));
    when(() => mockLocationManager.getCurrentLocationString())
        .thenAnswer((_) async => "Cairo, Egypt");
  });

  group('HomeBloc', () {
    group('Initialization (Started Event)', () {
      blocTest<HomeBloc, HomeState>(
        'sets empty name when no user is logged in (Guest)',
        build: () {
          when(() => mockPrefs.loggedIn).thenReturn(false);
          when(() => mockPrefs.lookups).thenReturn(null);
          when(() => mockPrefs.userProfile).thenReturn(null);
          return HomeBloc(
              mockHomeClient, mockAuthClient, mockPrefs, mockLocationManager);
        },
        act: (bloc) => bloc.add(const HomeEvent.started()),
        expect: () => [
          isA<HomeState>()
              .having((s) => s.isInitializing, 'isInitializing', true)
              .having((s) => s.isLoggedIn, 'isLoggedIn', false),
          isA<HomeState>()
              .having((s) => s.isInitializing, 'isInitializing', true)
              .having((s) => s.popularViewState, 'popularViewState', isA<NoData>()),
          isA<HomeState>()
              .having((s) => s.isInitializing, 'isInitializing', false)
              .having((s) => s.popularViewState, 'popularViewState',
                  ViewState.loaded),
          isA<HomeState>()
              .having((s) => s.location, 'location', 'Cairo, Egypt'),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'sets user name and avatar when user is logged in',
        build: () {
          final profile = Profile(
              fullName: 'John Doe',
              avatarUrl: 'https://example.com/avatar.png');
          when(() => mockPrefs.loggedIn).thenReturn(true);
          when(() => mockPrefs.lookups).thenReturn(null);
          when(() => mockPrefs.userProfile).thenReturn(profile);
          // Also mock the profile fetch during initialization
          when(() => mockAuthClient.getProfile())
              .thenAnswer((_) async => Success<Profile?, APIError>(profile));

          return HomeBloc(
              mockHomeClient, mockAuthClient, mockPrefs, mockLocationManager);
        },
        act: (bloc) => bloc.add(const HomeEvent.started()),
        expect: () => [
          isA<HomeState>()
              .having((s) => s.isInitializing, 'isInitializing', true)
              .having((s) => s.isLoggedIn, 'isLoggedIn', true)
              .having((s) => s.name, 'name', 'John Doe'),
          isA<HomeState>()
              .having((s) => s.isInitializing, 'isInitializing', true)
              .having((s) => s.popularViewState, 'popularViewState', isA<NoData>()),
          isA<HomeState>()
              .having((s) => s.isInitializing, 'isInitializing', false)
              .having((s) => s.viewState, 'viewState', ViewState.loaded),
          isA<HomeState>()
              .having((s) => s.location, 'location', 'Cairo, Egypt'),
        ],
      );
    });
  });
}
