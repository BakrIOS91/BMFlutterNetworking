import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/main_app/bloc/main_app_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

void main() {
  // Required because MainAppBloc accesses WidgetsBinding.instance.platformDispatcher
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockAppPreferences();
    when(() => mockPrefs.theme).thenReturn(ThemeMode.light);
  });

  group('MainAppBloc', () {
    test('initial state is correct', () {
      final bloc = MainAppBloc(mockPrefs);
      expect(bloc.state.mode, equals(ThemeMode.system));
      bloc.close();
    });

    blocTest<MainAppBloc, MainAppState>(
      'emits correct theme mode and updates language when started',
      build: () => MainAppBloc(mockPrefs),
      // Event is already added in constructor, but we can add it again or 
      // just wait for the one from constructor if we handle the build correctly.
      // Since it's added in constructor, it might emit before we can 'act'.
      // Testing the constructor-triggered emission:
      expect: () => [
        isA<MainAppState>().having((s) => s.mode, 'mode', ThemeMode.light),
      ],
      verify: (_) {
        if (Platform.isIOS) {
          verify(() => mockPrefs.currentLanguage = any())
              .called(greaterThanOrEqualTo(1));
        }
      },
    );
  });
}
