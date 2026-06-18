# Developer Onboarding Guide — `flutter_full_project`

> This document is the authoritative reference for any developer joining this project. Read it top to bottom before writing a single line of code.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Prerequisites & Setup](#2-prerequisites--setup)
3. [Project Structure](#3-project-structure)
4. [Core Architecture](#4-core-architecture)
   - 4.1 [Dependency Injection (GetIt + Injectable)](#41-dependency-injection-getit--injectable)
   - 4.2 [Navigation (AutoRoute)](#42-navigation-autoroute)
   - 4.3 [State Management (BLoC + Freezed)](#43-state-management-bloc--freezed)
   - 4.4 [Networking (ld_flutter)](#44-networking-ld_flutter)
   - 4.5 [Preferences & Secure Storage](#45-preferences--secure-storage)
   - 4.6 [Environment Variables (Envied)](#46-environment-variables-envied)
   - 4.7 [Theming](#47-theming)
   - 4.8 [Localisation (Flutter l10n)](#48-localisation-flutter-l10n)
5. [Feature Structure — The Standard Pattern](#5-feature-structure--the-standard-pattern)
6. [Services Layer](#6-services-layer)
7. [Utilities Layer](#7-utilities-layer)
8. [Code Generation](#8-code-generation)
9. [Testing](#9-testing)
10. [Key Packages Cheat-Sheet](#10-key-packages-cheat-sheet)
11. [Do's and Don'ts](#11-dos-and-donts)

---

## 1. Project Overview

`flutter_full_project` is a production-ready Flutter template that targets **iOS and Android**. It combines:

| Concern | Solution |
|---|---|
| State management | BLoC |
| DI / IoC | GetIt + Injectable |
| Routing | AutoRoute |
| Immutable models / events / states | Freezed |
| Networking | `ld_flutter` (internal package) |
| Persistent storage | `ld_flutter` `BasePreferences` (wrapper over SharedPreferences + FlutterSecureStorage) |
| Push notifications | Firebase Cloud Messaging |
| Crash reporting | Firebase Crashlytics |
| Localisation | Flutter's built-in `gen-l10n` |
| Environment config | Envied (compile-time env vars) |

The app entry point is `lib/main.dart`.

---

## 2. Prerequisites & Setup

### 2.1 Install tooling

```bash
# Flutter SDK (match version in .fvmrc / pubspec environment field)
flutter --version   # must be >= 3.24.x for Dart >= 3.4.8

# Firebase CLI (for FCM / Crashlytics)
firebase --version
```

### 2.2 Environment file

The app reads secrets from a `.env` file **at compile time** via `envied`. Copy the template provided by the team and place it at the project root:

```
iOS - Flutter/
└── .env          ← never commit this file
```

The `.env` must contain at minimum:

```
BASE_URL=
API_PATH=
API_MAIN_PATH=
API_AUTH_MAIN_PATH=
IOS_NOTIFICATION_BUNDLE_ID=
```

These values are read by `lib/core/env/env.dart` (generated — do **not** edit `env.g.dart` manually).

### 2.3 First-time setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Run code generators (required after every model/router/pref change)
dart run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

> ⚠️ If you skip step 2 you will get missing file / undefined class errors. Always run `build_runner` after pulling changes that touch annotated files (`@freezed`, `@injectable`, `@RoutePage`, `@GeneratePreferences`, `@Envied`).

---

## 3. Project Structure

```
lib/
├── main.dart                  # App entry point
├── core/                      # App-wide infrastructure (no business logic)
│   ├── dependency_injector/   # GetIt container setup
│   ├── env/                   # Compile-time environment variables
│   ├── notification_services/ # FCM / local notification wiring
│   ├── preferences/           # Persistent user state (AppPreferences)
│   ├── router/                # AutoRoute configuration
│   └── theme/                 # ThemeData, text styles, button styles, input styles
├── features/                  # One directory per screen / feature
│   ├── splash_view/
│   ├── onboarding_view/
│   ├── auth/
│   │   ├── login_feature/
│   │   └── register_feature/
│   ├── main_app/
│   ├── tab_view/
│   └── account-info/
├── services/                  # Network clients & data models
│   ├── app_targets.dart       # Base URL / path configuration per environment
│   ├── app_token_refresh_handler.dart
│   ├── authorized.dart
│   ├── client/                # One *Client class per API domain
│   ├── models/                # Freezed response/request models
│   └── requests/              # TargetType request definitions
├── utilities/                 # Stateless helpers shared across the app
│   ├── constants/             # Enums, colors, image asset paths
│   ├── extensions/            # BuildContext, String, etc. extensions
│   ├── helpers/               # Validation, formatting
│   ├── l10n/                  # Language manager + generated ARB strings
│   └── reusables/             # Shared widgets (WithViewState, AppTextField, …)
test/
└── *_test.dart               # Unit tests (BLoC-focused)
```

---

## 4. Core Architecture

### 4.1 Dependency Injection (GetIt + Injectable)

**Files:** `lib/core/dependency_injector/dependency_injector.dart` and the generated `dependency_injector.config.dart`.

GetIt is the service locator. Injectable generates all registration boilerplate.

```dart
// lib/core/dependency_injector/dependency_injector.dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

`configureDependencies()` is called once in `main()` before `runApp`.

#### Annotation reference

| Annotation | Lifetime | When to use |
|---|---|---|
| `@singleton` | Single instance for app lifetime | Router, ThemeFactory, AppPreferences |
| `@LazySingleton()` | Created on first access | Network clients |
| `@Injectable()` | New instance each time resolved | BLoC classes |
| `@preResolve` | Async factory (awaited during setup) | AppPreferences (needs async `init()`) |

#### Resolving dependencies

```dart
// In a view (preferred pattern: via AutoRoute's wrappedRoute)
getIt<SplashBloc>()

// Anywhere in the codebase
getIt<AppPreferences>()
```

> **Rule:** Never instantiate injected classes with `new MyClass()`. Always go through `getIt<T>()` so the container manages lifetimes.

---

### 4.2 Navigation (AutoRoute)

**Files:** `lib/core/router/app_router.dart` and generated `app_router.gr.dart`.

```dart
@singleton
@AutoRouterConfig(replaceInRouteName: 'View|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: TabRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: AccountInfoRoute.page),
  ];
}
```

#### Registering a new screen

1. Create your view class annotated with `@RoutePage()`:

```dart
@RoutePage()
class MyNewView extends StatelessWidget { … }
```

2. Add it to `AppRouter.routes`:

```dart
AutoRoute(page: MyNewRoute.page),
```

3. Run `build_runner` to regenerate `app_router.gr.dart`.

#### Navigating

```dart
// Push
context.router.push(const LoginRoute());

// Replace current (no back arrow)
context.router.replace(const TabRoute(pref: getIt()));

// Pop
context.router.pop();
```

Navigation **must never be called directly from a BLoC**. Set a navigation enum value in the state and handle it inside a `BlocListener` in the view:

```dart
BlocListener<LoginBloc, LoginState>(
  listenWhen: (prev, curr) => prev.navigation != curr.navigation,
  listener: (context, state) {
    switch (state.navigation) {
      case LoginNavigation.tab: context.router.replace(…);
      case LoginNavigation.none: break;
    }
  },
)
```

---

### 4.3 State Management (BLoC + Freezed)

Every feature uses a **strict BLoC pattern**. The structure is always the same three files inside `bloc/`:

```
bloc/
├── my_feature_bloc.dart      # Business logic + parts declaration
├── my_feature_event.dart     # Freezed union of all inputs
└── my_feature_state.dart     # Freezed data class for UI state
```

(Plus generated `my_feature_bloc.freezed.dart` — never edit this.)

#### Event file (`my_feature_event.dart`)

```dart
part of 'my_feature_bloc.dart';

@freezed
class MyFeatureEvent with _$MyFeatureEvent {
  const factory MyFeatureEvent.started() = _Started;
  const factory MyFeatureEvent.didPressSubmit() = _DidPressSubmit;
  const factory MyFeatureEvent.someResponse(Result<MyModel?, APIError> result) = _SomeResponse;
}
```

- Use descriptive, **action-verb** factory names.
- Async API responses are their own events (e.g. `loginResponse`) — they are dispatched inside `_onEvent` after `await`.

#### State file (`my_feature_state.dart`)

```dart
part of 'my_feature_bloc.dart';

@freezed
abstract class MyFeatureState with _$MyFeatureState {
  const factory MyFeatureState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(MyNavigation.none) MyNavigation navigation,
    // … other UI fields
  }) = _MyFeatureState;

  factory MyFeatureState.initial() => const MyFeatureState();
}

enum MyNavigation { none, nextScreen }
```

- `ViewState` (from `ld_flutter`) handles `loading`, `loaded`, `error`, `jailBroken`, etc.
- Always define a navigation enum with at minimum `none`. Do not put route calls in the BLoC.

#### BLoC file (`my_feature_bloc.dart`)

```dart
part 'my_feature_bloc.freezed.dart';
part 'my_feature_event.dart';
part 'my_feature_state.dart';

@Injectable()                           // ← DI annotation
class MyFeatureBloc extends Bloc<MyFeatureEvent, MyFeatureState> {
  final AppPreferences _pref;
  final MyClient _client;

  MyFeatureBloc(this._pref, this._client) : super(MyFeatureState.initial()) {
    on<MyFeatureEvent>(_onEvent);       // ← single handler, switch inside
  }

  Future<void> _onEvent(MyFeatureEvent event, Emitter<MyFeatureState> emit) async {
    event.when(
      started: () async { … },
      didPressSubmit: () async {
        emit(state.copyWith(viewState: ViewState.loading));
        add(MyFeatureEvent.someResponse(await _client.doSomething()));
      },
      someResponse: (result) {
        result.when(
          success: (data) { emit(state.copyWith(viewState: ViewState.loaded, …)); },
          failure: (error) { emit(state.copyWith(viewState: ViewState.failHandler(error))); },
        );
      },
    );
  }
}
```

Key rules:
- Use `event.when(…)` (exhaustive), not `if/else` chains.
- Dispatch async results as child events (`add(MyFeatureEvent.someResponse(await …))`).
- Never call `context.router` or use `BuildContext` from a BLoC.

---

### 4.4 Networking (ld_flutter)

All network calls go through the internal `ld_flutter` package. The pattern:

1. **Define a request** in `services/requests/` by extending `TargetType`:

```dart
class GetLookups extends TargetType {
  final String language;
  GetLookups(this.language);

  @override
  String get path => '/lookups';

  @override
  Method get method => Method.get;

  @override
  Target get target => AppTarget();

  // headers, body, query params …
}
```

2. **Create a Client** in `services/client/`:

```dart
@LazySingleton()
class CommonClient {
  final AppPreferences _pref;
  CommonClient(this._pref);

  Future<Result<Lookup?, APIError>> getLookups() =>
      GetLookups(_pref.currentLanguage).performResult();
}
```

3. **Call the client from a BLoC** and dispatch the result:

```dart
add(SplashEvent.lookupResponse(await commonClient.getLookups()));
```

4. **Handle the result** in a `Result.when`:

```dart
result.when(
  success: (data) { … },
  failure: (error) { emit(state.copyWith(viewState: ViewState.failHandler(error))); },
);
```

#### Multiple targets

The app separates API endpoints into targets:

| Target | Usage |
|---|---|
| `AppTarget` | Main application APIs |
| `AuthAppTarget` | Authentication APIs (different base path) |

Both read their URLs from `Env.*` (set via `.env`).

#### Token refresh

Token refresh is handled globally by `AppTokenRefreshHandler` registered in `main()`:

```dart
TokenRefreshRegistry.register(getIt<AppTokenRefreshHandler>());
```

All network clients automatically benefit from this — no per-request refresh logic needed.

---

### 4.5 Preferences & Secure Storage

**File:** `lib/core/preferences/app_preferences.dart`

`AppPreferences` extends `BasePreferences` (from `ld_flutter`) and uses `@GeneratePreferences()` to auto-generate typed getters/setters.

#### Storage annotations

| Annotation | Storage backend | Cleared on logout? |
|---|---|---|
| `@InApp()` | In-memory only, reset each launch | N/A |
| `@UserDefault('key')` | `SharedPreferences` | No (survives reinstall) |
| `@Secure('key')` | `FlutterSecureStorage` (Keychain/Keystore) | Yes (cleared on fresh install) |

#### Adding a new preference

1. Declare the backing field in `AppPreferences`:

```dart
@override
@UserDefault('kMyNewPref')
late final bool _myNewPref = false;
```

2. Run `build_runner` — generates the getter/setter in `app_preferences.pref.g.dart`.

3. Access it anywhere via `getIt<AppPreferences>().myNewPref`.

> Sensitive data (tokens, credentials, profile) **must** use `@Secure`. Non-sensitive app state (theme, language) uses `@UserDefault`. Ephemeral in-session state uses `@InApp`.

---

### 4.6 Environment Variables (Envied)

**File:** `lib/core/env/env.dart`

The `@Envied` annotation reads values from `.env` at build time and obfuscates them in the binary:

```dart
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static final String baseUrl = _Env.baseUrl;
  // …
}
```

**Never hardcode secrets**. Always add new secrets to `.env` and expose them through `Env`.

---

### 4.7 Theming

**Files:** `lib/core/theme/`

| File | Purpose |
|---|---|
| `theme_factory.dart` | Builds `ThemeData` for light and dark modes |
| `app_text_styles.dart` | Centralised `TextStyle` definitions mapped to `TextTheme` slots |
| `app_button_styles.dart` | Primary, secondary, and platform-adaptive button styles (mandatory for all buttons) |
| `app_input_styles.dart` | `InputDecorationTheme` for all text fields |
| `color_constants.dart` | `AppColors(brightness)` colour palette |

#### Using colours and text styles in a widget

```dart
// Colours (brightness-aware)
context.colors.primary        // from ld_flutter extension

// Text styles
Theme.of(context).textTheme.headlineLarge   // Big Title — Bold — 18
Theme.of(context).textTheme.bodyMedium      // Body Medium — Regular — 16

// Buttons (Use platform-adaptive variants where possible)
AppButtonStyles.primaryPlatform(context: context, title: '…', onPressed: …)
```

The font family is **Jost** (weights 400/500/600/700, bundled in `assets/fonts/`).

---

### 4.8 Localisation (Flutter l10n)

**Config:** `l10n.yaml`  
**ARB files:** `lib/utilities/l10n/*.arb`

To add a new string:

1. Add the key to the `.arb` files.
2. Run `flutter gen-l10n` or re-run `flutter pub get` (it is triggered automatically).
3. Access via:

```dart
context.localization.my_new_key
// equivalent to AppLocalizations.of(context)!.my_new_key
```

---

## 5. Feature Structure — The Standard Pattern

Every feature **must** follow this directory layout:

```
features/my_feature/
├── bloc/
│   ├── my_feature_bloc.dart      # contains parts + BLoC class
│   ├── my_feature_bloc.freezed.dart  # generated — do not edit
│   ├── my_feature_event.dart     # Freezed union (part of bloc)
│   └── my_feature_state.dart     # Freezed state + nav enum (part of bloc)
└── view/
    ├── my_feature_view.dart      # @RoutePage() widget + BlocProvider via wrappedRoute
    └── widgets/                  # Private sub-widgets (mandatory for decomposition)
        ├── my_feature_header.dart
        └── …
```

#### View Decomposition
Large view files are prohibited. Every complex screen must be divided into smaller, focused child widgets within the local `widgets/` directory. This keeps the main view file clean and improves maintainability.

#### Routing & BLoC Lifecycle
The project uses two patterns for BLoC initialization depending on whether the view is a direct route or a child component:

1. **Routable Views**: Must implement `AutoRouteWrapper` and initialize the BLoC in `wrappedRoute`. This ensures the BLoC is provided to the entire route.
2. **Non-Routable Views (Child/Tabs)**: Must receive their BLoC providers from the parent view. Do not initialize BLoCs inside child components that are not independent routes.

#### View boilerplate (Routable)

```dart
@RoutePage()
class MyFeatureView extends StatefulWidget implements AutoRouteWrapper {
  const MyFeatureView({super.key});

  @override
  State<MyFeatureView> createState() => _MyFeatureViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    // Inject BLoC and dispatch started event here
    return BlocProvider(
      create: (_) => getIt<MyFeatureBloc>()..add(const MyFeatureEvent.started()),
      child: this,
    );
  }
}
```

Use `WithViewState` (from `utilities/reusables/`) to handle loading/error UI automatically:

```dart
WithViewState(
  viewState: state.viewState,
  retryAction: () => context.read<MyFeatureBloc>().add(const MyFeatureEvent.started()),
  errorDisplayMode: ErrorDisplayMode.bottomSheet, // or .inline
  child: MyActualContent(),
)
```

---

## 6. Services Layer

```
services/
├── app_targets.dart           # AppTarget + AuthAppTarget (base URLs per environment)
├── app_token_refresh_handler.dart  # Token renewal logic
├── authorized.dart            # Auth interceptor / header helper
├── client/
│   ├── common_client.dart     # General endpoints (lookups, etc.)
│   └── auth_client.dart       # Auth endpoints (login, register, profile)
├── models/
│   ├── auth/                  # Login / Register / Profile models
│   └── lookups/               # Lookup model
└── requests/
    └── *.dart                 # TargetType definitions (One per endpoint)
```

### API Implementation Pattern

The project follows a strict request-based pattern:

1. **Request Definition**: Every API endpoint is defined as a class extending `ModelTargetType<T>` or `SuccessTargetType` in `lib/services/requests/`.
2. **Client Layer**: Service clients in `lib/services/client/` act as thin wrappers that call `performResult()` on the request objects.
3. **Result Handling**: All client methods must return a `Result<T, APIError>`. BLoCs handle these results using `result.when()`, mapping successes to data updates and failures to `ViewState.failHandler(error)`.

### Adding a new endpoint

1. **Request** — create `services/requests/my_endpoint_request.dart` extending `TargetType`.
2. **Model** — create a `@freezed` model in `services/models/my_domain/`.
3. **Client** — add the method to an existing `*Client` or create a new `@LazySingleton()` class.
4. **BLoC** — inject the client, call it, dispatch the result as an event.
5. **Run `build_runner`** to regenerate Freezed files.

---

## 7. Utilities Layer

```
utilities/
├── constants/
│   ├── app_enums.dart         # App-wide enums (EmailErrorType, etc.)
│   ├── color_constants.dart   # AppColors(brightness) palette
│   └── image_constants.dart   # Asset path constants
├── extensions/
│   └── context_extension.dart # context.scale, context.colors, context.localization, etc.
├── helpers/
│   └── validation_helper.dart # Static helpers: isValidEmail, etc.
├── l10n/
│   └── app_language_manager.dart  # Manages locale switching
└── reusables/
    ├── with_view_state.dart   # Wraps child in loading/error shell
    ├── app_text_field.dart    # Themed text field widget
    ├── app_error_view.dart    # Error page widget
    └── status_bottom_sheet.dart  # Reusable status feedback sheet
```

> Put code here only if it is **truly reusable across at least two features**. Otherwise it belongs inside the feature's own `view/widgets/` folder.

---

## 8. Code Generation

This project heavily relies on `build_runner`. You **must** regenerate after changing:

| What changed | Files to regenerate |
|---|---|
| `@freezed` models/events/states | `*.freezed.dart` |
| `@RoutePage()` views or `AppRouter.routes` | `app_router.gr.dart` |
| `@injectable` / `@singleton` annotations | `dependency_injector.config.dart` |
| `@Envied` fields | `env.g.dart` |
| `@GeneratePreferences()` fields | `app_preferences.pref.g.dart` |

```bash
# One-shot regeneration (recommended)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

> **Never manually edit** any `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, or `*.g.dart` file. They will be overwritten.

---

## 9. Testing

Tests live in `test/` and follow a **BLoC unit test** pattern using `bloc_test` + `mocktail`.

### Test anatomy

```dart
// 1. Declare mocks — one per injected dependency
class MockAppPreferences extends Mock implements AppPreferences {}
class MockMyClient extends Mock implements MyClient {}

void main() {
  // 2. Register GetIt mocks in setUp / unregister in tearDown
  setUp(() {
    getIt.registerSingleton<AppPreferences>(MockAppPreferences());
    // stub required methods
    when(() => mockPrefs.someFlag).thenReturn(true);
  });

  tearDown(() {
    if (getIt.isRegistered<AppPreferences>()) {
      getIt.unregister<AppPreferences>();
    }
  });

  // 3. Use blocTest for each scenario
  group('MyFeatureBloc', () {
    blocTest<MyFeatureBloc, MyFeatureState>(
      'emits expected state when event is dispatched',
      build: () => MyFeatureBloc(pref: mockPrefs, client: mockClient),
      act: (bloc) => bloc.add(const MyFeatureEvent.started()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        MyFeatureState.initial().copyWith(viewState: ViewState.loaded),
      ],
    );
  });
}
```

### Running tests

```bash
# All tests
flutter test

# Single file
flutter test test/splash_test.dart

# With coverage
flutter test --coverage
```

### Testing rules
- Mock every external dependency (`AppPreferences`, `*Client`, `NotificationService`).
- Always clean up `getIt` in `tearDown` to avoid test pollution.
- Use `registerFallbackValue` for any type used in `any()` matchers.
- Test one behaviour per `blocTest`. Group related cases under `group()`.

---

## 10. Key Packages Cheat-Sheet

| Package | Purpose | Docs |
|---|---|---|
| `bloc` / `flutter_bloc` | State management | [bloclibrary.dev](https://bloclibrary.dev) |
| `freezed` | Immutable unions & value classes | [pub.dev/packages/freezed](https://pub.dev/packages/freezed) |
| `auto_route` | Type-safe declarative routing | [pub.dev/packages/auto_route](https://pub.dev/packages/auto_route) |
| `get_it` / `injectable` | Dependency injection | [pub.dev/packages/injectable](https://pub.dev/packages/injectable) |
| `envied` | Compile-time obfuscated env vars | [pub.dev/packages/envied](https://pub.dev/packages/envied) |
| `bloc_test` | BLoC unit testing helpers | [pub.dev/packages/bloc_test](https://pub.dev/packages/bloc_test) |
| `mocktail` | Mock creation for tests | [pub.dev/packages/mocktail](https://pub.dev/packages/mocktail) |
| `ld_flutter` | Internal: networking, DI base, preferences | Azure DevOps (internal) |
| `firebase_core` + `firebase_messaging` + `firebase_crashlytics` | Push notifications & crash reporting | Firebase docs |

---

## 11. Do's and Don'ts

### ✅ Do

- Run `build_runner` after any annotated-file change.
- Use `getIt<T>()` for all dependency resolution.
- Keep all navigation logic in the **View** layer via `BlocListener`.
- Use `ViewState.failHandler(error)` to propagate API errors to the UI.
- Store secrets only in `.env` and expose them through `Env` class.
- Add `@RoutePage()` + `wrappedRoute` to every new screen view.
- Divide large view files into small components in a local `widgets/` folder.
- Write a `blocTest` for every new BLoC event.

### ❌ Don't

- Hardcode secrets, base URLs, or API keys anywhere in Dart code.
- Edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`).
- Call `context.router` from inside a BLoC.
- Use `setState` for business logic — that belongs in the BLoC.
- Skip the `tearDown` GetIt cleanup in tests.
- Create a new `GetIt` instance — always use the global `getIt`.
- Commit `.env` to source control.
