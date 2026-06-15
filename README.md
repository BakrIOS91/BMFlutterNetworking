# BMFlutterNetworking

A structured Flutter networking layer providing type-safe API requests, automatic token refresh, custom error mapping, and SSL pinning.

---

## Table of Contents

- [Installation](#installation)
- [Architecture Overview](#architecture-overview)
- [Step 1 — Define Your Targets](#step-1--define-your-targets)
- [Step 2 — Create Request Classes](#step-2--create-request-classes)
- [Step 3 — The Authorized Mixin](#step-3--the-authorized-mixin)
- [Step 4 — Build a Client Layer](#step-4--build-a-client-layer)
- [Step 5 — Handle Errors (APIErrorResponseMapper)](#step-5--handle-errors-apierrorresponsemapper)
- [Step 6 — Token Refresh (TokenRefreshHandler)](#step-6--token-refresh-tokenrefreshhandler)
- [Step 7 — Initialize in main()](#step-7--initialize-in-main)
- [Request Types Reference](#request-types-reference)
- [Response Methods Reference](#response-methods-reference)
- [Working with Cookies](#working-with-cookies)
- [File Downloads](#file-downloads)
- [File Uploads](#file-uploads)
- [SSL Pinning](#ssl-pinning)
- [Logging](#logging)
- [Network Connectivity](#network-connectivity)

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  bm_flutter_networking:
    git:
      url: https://github.com/bakrmohamed/BMFlutterNetworking
      ref: 0.1.0
```

---

## Architecture Overview

```
main.dart
  └─ registers TokenRefreshRegistry & APIErrorResponseRegistry
       │
       ▼
Target (base URL + environment config)
       │
       ▼
ModelTargetType / SuccessTargetType  (one class per endpoint)
       │
       ▼
Client  (thin wrapper that calls performResult / performAsync)
       │
       ▼
Repository / ViewModel / BLoC
```

Every API call flows through a **request class** that knows its own URL, method, headers, and parameters. The client layer is just a façade that groups related requests together and returns `Result<T, APIError>` to callers.

---

## Step 1 — Define Your Targets

A `Target` holds your base URL configuration. Create one subclass per distinct API origin (main API, auth API, CDN, etc.).

```dart
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

// A global app environment value — set this before runApp().
late AppEnvironment appEnv;

// ── Main API target ───────────────────────────────────────────────────────────
class AppApiTarget extends Target {
  @override
  AppEnvironment get appEnvironment => appEnv;

  @override
  String get kAppScheme => 'https';

  @override
  String get kAppHost {
    switch (appEnvironment) {
      case AppEnvironment.production:
        return 'api.example.com';
      case AppEnvironment.staging:
        return 'staging.api.example.com';
      case AppEnvironment.development:
        return 'dev.api.example.com';
    }
  }

  @override
  String? get kMainAPIPath => 'api';   // https://api.example.com/api/
  
  @override
  String? get kAppApiPath => 'v1';     // https://api.example.com/api/v1/
}

// ── Auth API target (different subdomain / path) ──────────────────────────────
class AuthApiTarget extends Target {
  @override
  AppEnvironment get appEnvironment => appEnv;

  @override
  String get kAppScheme => 'https';

  @override
  String get kAppHost => 'auth.example.com';

  @override
  String? get kMainAPIPath => 'oauth';
}
```

**How the base URL is composed:**

| Property | Example value | Result |
|---|---|---|
| `kAppScheme` | `https` | `https://` |
| `kAppHost` | `api.example.com` | `https://api.example.com` |
| `kMainAPIPath` | `api` | `https://api.example.com/api/` |
| `kAppApiPath` | `v1` | `https://api.example.com/api/v1/` |

Access the final URL via `AppApiTarget().kBaseURL`.

---

## Step 2 — Create Request Classes

Each endpoint gets its own class. Use `ModelTargetType<T>` when the response deserializes into a model, and `SuccessTargetType` when you only care whether the call succeeded.

### GET with query parameters

```dart
// Response model
class ProductList {
  final List<Product> items;
  const ProductList({required this.items});

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
    items: (json['items'] as List).map((e) => Product.fromJson(e)).toList(),
  );
}

// Request class
final class GetProducts extends ModelTargetType<ProductList> {
  final String category;
  final int page;

  GetProducts({required this.category, this.page = 1})
      : super(decoder: ProductList.fromJson);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => 'products';

  @override
  RequestTask get requestTask => RequestTask.parameters({
    'category': category,
    'page': page,
  });
}
```

### POST with JSON body

```dart
class AuthToken {
  final String accessToken;
  final String refreshToken;

  const AuthToken({required this.accessToken, required this.refreshToken});

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
  );
}

final class LoginRequest extends ModelTargetType<AuthToken> {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password})
      : super(decoder: AuthToken.fromJson);

  @override
  String get baseURL => AuthApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => 'token';

  @override
  RequestTask get requestTask => RequestTask.encodedBody({
    'email': email,
    'password': password,
    'grant_type': 'password',
  });
}
```

### POST with both query params and body

```dart
final class SearchRequest extends ModelTargetType<SearchResult> {
  final String query;
  final Map<String, dynamic> filters;

  SearchRequest({required this.query, required this.filters})
      : super(decoder: SearchResult.fromJson);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => 'search';

  @override
  RequestTask get requestTask => RequestTask.parametersAndBody(
    {'q': query},   // query string
    filters,        // JSON body
  );
}
```

### Void / success-only request

```dart
final class DeleteAccountRequest extends SuccessTargetType {
  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.delete;

  @override
  String get requestPath => 'account';
}
```

### Override `fromJson` instead of using a decoder

```dart
final class GetUserProfile extends ModelTargetType<UserProfile> {
  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => 'profile';

  @override
  UserProfile fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    displayName: json['display_name'],
    avatarUrl: json['avatar_url'],
  );
}
```

---

## Step 3 — The Authorized Mixin

Rather than repeating `isAuthorized`, auth headers, and API-key headers in every request class, define a mixin once and apply it where needed.

```dart
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

mixin Authorized on TargetRequest {
  // Inject or access your token storage here (GetIt, Riverpod, etc.)
  static TokenStorage get _tokens => getIt<TokenStorage>();

  @override
  bool get isAuthorized => true;  // triggers automatic 401 → refresh → retry

  @override
  Map<String, String> get headers => {
    'x-api-key': Env.apiKey,
  };

  @override
  Map<String, String> get authHeaders {
    final token = _tokens.accessToken;
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }
}
```

Apply it to any request class:

```dart
final class GetUserProfile extends ModelTargetType<UserProfile> with Authorized {
  GetUserProfile() : super(decoder: UserProfile.fromJson);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => 'profile';
}

final class UpdateNotificationSettings extends SuccessTargetType with Authorized {
  final bool enabled;

  UpdateNotificationSettings({required this.enabled});

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.patch;

  @override
  String get requestPath => 'settings/notifications';

  @override
  RequestTask get requestTask => RequestTask.encodedBody({'enabled': enabled});
}
```

When an authorized request receives a **401 Unauthorized** response, the layer automatically:
1. Calls `TokenRefreshRegistry.refreshToken()`
2. Rebuilds the request (picking up fresh tokens from `authHeaders`)
3. Retries once

---

## Step 4 — Build a Client Layer

Clients are thin wrappers that group related requests. They translate request objects into `Result<T, APIError>` values that repositories and view models consume.

```dart
import 'package:injectable/injectable.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

@lazySingleton
class ProductClient {
  Future<Result<ProductList, APIError>> getProducts({
    required String category,
    int page = 1,
  }) => GetProducts(category: category, page: page).performResult();

  Future<Result<Product, APIError>> getProductDetail(String id) =>
      GetProductDetail(id: id).performResult();

  Future<Result<void, APIError>> addToCart(String productId, int qty) =>
      AddToCartRequest(productId: productId, qty: qty).performResult();
}

@lazySingleton
class AuthClient {
  Future<Result<AuthToken, APIError>> login(String email, String password) =>
      LoginRequest(email: email, password: password).performResult();

  Future<Result<AuthToken, APIError>> refreshToken(String token) =>
      RefreshTokenRequest(token: token).performResult();

  Future<Result<void, APIError>> logout() =>
      LogoutRequest().performResult();
}
```

Consuming the result in a repository:

```dart
class ProductRepository {
  final ProductClient _client;

  ProductRepository(this._client);

  Future<void> loadProducts(String category) async {
    final result = await _client.getProducts(category: category);

    result.when(
      success: (productList) {
        // update state with productList.items
      },
      failure: (error) {
        // handle error.type, error.statusCode, error.errorModel
      },
    );
  }
}
```

---

## Step 5 — Handle Errors (APIErrorResponseMapper)

When an HTTP error response contains a JSON body with extra detail (error code, message, etc.), implement `APIErrorResponseMapper` to decode it into your own model. This decoded object is attached to `APIError.errorModel`.

```dart
// Your custom error model
class ApiErrorResponse {
  final int? code;
  final String? errorCode;
  final String? message;

  const ApiErrorResponse({this.code, this.errorCode, this.message});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      ApiErrorResponse(
        code: json['code'],
        errorCode: json['error_code'],
        message: json['message'],
      );
}

// The mapper
class AppErrorResponseMapper implements APIErrorResponseMapper {
  @override
  dynamic decode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ApiErrorResponse.fromJson(json);
    }
    return null;
  }
}
```

Reading the error model after a failed request:

```dart
result.when(
  success: (_) { /* ... */ },
  failure: (error) {
    final detail = error.errorModel as ApiErrorResponse?;
    final userMessage = detail?.message ?? 'Something went wrong';
    // show userMessage
  },
);
```

Register it once at startup (see [Step 7](#step-7--initialize-in-main)).

---

## Step 6 — Token Refresh (TokenRefreshHandler)

Implement `TokenRefreshHandler` to tell the layer how to obtain a new access token. The built-in mutex ensures this is called only **once** even if multiple authorized requests receive a 401 simultaneously.

```dart
import 'package:injectable/injectable.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

@singleton
class AppTokenRefreshHandler implements TokenRefreshHandler {
  final TokenStorage _storage;
  final AuthClient _authClient;

  AppTokenRefreshHandler(this._storage, this._authClient);

  @override
  Future<bool> refreshToken() async {
    final storedRefreshToken = _storage.refreshToken;
    if (storedRefreshToken == null) return false;

    final result = await _authClient.refreshToken(storedRefreshToken);

    return result.when(
      success: (newTokens) {
        _storage.saveTokens(newTokens);   // persist fresh tokens
        return true;
      },
      failure: (_) => false,
    );
  }
}
```

- Return `true` if the refresh succeeded — the original request will be retried with the new token from `authHeaders`.
- Return `false` or throw if refresh failed — the original 401 error propagates to the caller.

Register it once at startup (see [Step 7](#step-7--initialize-in-main)).

---

## Step 7 — Initialize in main()

Register the handlers **before** `runApp()`. Dependency injection must be set up first so the handlers can receive their injected dependencies.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appEnv = AppEnvironment.production; // or read from --dart-define

  // 1. Set up DI (GetIt/Injectable, Riverpod, etc.)
  await configureDependencies();

  // 2. Register the token refresh handler
  TokenRefreshRegistry.register(getIt<AppTokenRefreshHandler>());

  // 3. Register the error response mapper
  APIErrorResponseRegistry.register(AppErrorResponseMapper());

  runApp(const MyApp());
}
```

> **Order matters.** `TokenRefreshRegistry` and `APIErrorResponseRegistry` must be populated before the first network call executes.

---

## Request Types Reference

| Factory | When to use |
|---|---|
| `RequestTask.plain()` | GET with no parameters (default) |
| `RequestTask.parameters(Map)` | Query string parameters |
| `RequestTask.encodedBody(dynamic)` | JSON body (POST / PUT / PATCH) |
| `RequestTask.parametersAndBody(Map, dynamic)` | Query params **and** JSON body |
| `RequestTask.uploadFile(String path)` | Single binary file upload |
| `RequestTask.uploadMultipart(Map<String, MultipartFormData>)` | Multipart form fields / files |
| `RequestTask.download(String url)` | Download a file from a full URL |
| `RequestTask.downloadResumable({int? offset})` | Resumable download (Range header) |

### Multipart upload example

```dart
final class UploadAvatarRequest extends SuccessTargetType with Authorized {
  final Uint8List imageBytes;
  final String filename;

  UploadAvatarRequest({required this.imageBytes, required this.filename});

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => 'profile/avatar';

  @override
  RequestTask get requestTask => RequestTask.uploadMultipart({
    'avatar': MultipartFormDataData(
      data: imageBytes,
      fileName: filename,
      mimeType: 'image/jpeg',
    ),
    'description': const MultipartFormDataText('Profile picture'),
  });
}
```

---

## Response Methods Reference

All response methods are available on both `ModelTargetType` and `SuccessTargetType`.

| Method | Returns | Throws on error |
|---|---|---|
| `performAsync<T>()` | `T` | Yes — throws `APIError` |
| `performResult<T>()` | `Result<T, APIError>` | No — wraps in `Failure` |
| `performAsyncWithCookies<T>()` | `NetworkResponse<T>` | Yes — throws `APIError` |
| `performResultWithCookies<T>()` | `Result<NetworkResponse<T>, APIError>` | No — wraps in `Failure` |
| `performDownload()` | `DownloadedFile?` | Yes — throws `APIError` |
| `performDownloadResult()` | `Result<DownloadedFile?, APIError>` | No — wraps in `Failure` |

**Prefer `performResult` / `performDownloadResult`** in production code — they never throw, and the `Result` type forces you to handle both outcomes at compile time.

```dart
// ✅ Recommended — compile-safe, no try/catch needed
final result = await GetProducts(category: 'electronics').performResult<ProductList>();
result.when(
  success: (list) => print(list.items.length),
  failure: (err) => print(err.type),
);

// ⚠️ Only use performAsync when you're intentionally letting errors propagate
try {
  final list = await GetProducts(category: 'electronics').performAsync<ProductList>();
} on APIError catch (e) {
  print(e.statusCode);
}
```

### APIError fields

| Field | Type | Description |
|---|---|---|
| `type` | `APIErrorType` | `.noNetwork`, `.httpError`, `.dataConversionFailed`, `.invalidURL`, … |
| `statusCode` | `HTTPStatusCode?` | `.success`, `.notAuthorize`, `.notFound`, `.clientError`, `.serverError` |
| `errorModel` | `dynamic` | Decoded by `APIErrorResponseMapper`, cast to your error model |

---

## Working with Cookies

Use the `WithCookies` variants when you need to read `Set-Cookie` headers from the response (e.g. session management).

```dart
final response = await LoginRequest(email: email, password: password)
    .performAsyncWithCookies<AuthToken>();

final token = response.data;            // the decoded AuthToken
final sessionCookie = response.cookies  // List<Cookie>
    .firstWhere((c) => c.name == 'session', orElse: () => Cookie('', ''));
final rawHeader = response.rawSetCookieHeader;  // original Set-Cookie string
```

---

## File Downloads

```dart
final class DownloadInvoiceRequest extends ModelTargetType<void> with Authorized {
  final String invoiceId;

  DownloadInvoiceRequest(this.invoiceId);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => 'invoices/$invoiceId/pdf';

  @override
  RequestTask get requestTask =>
      RequestTask.download('https://files.example.com/invoices/$invoiceId.pdf');

  @override
  bool get useUniqueFilename => true; // avoids overwriting existing files
}
```

```dart
final result = await DownloadInvoiceRequest(invoiceId).performDownloadResult();

result.when(
  success: (file) {
    if (file != null) {
      print('Saved to: ${file.downloadedUrl}');
    }
  },
  failure: (error) => print('Download failed: ${error.type}'),
);
```

---

## File Uploads

### Single file

```dart
final class UploadDocumentRequest extends SuccessTargetType with Authorized {
  final String filePath;

  UploadDocumentRequest(this.filePath);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => 'documents';

  @override
  RequestTask get requestTask => RequestTask.uploadFile(filePath);
}
```

### Multipart with metadata fields

```dart
final class CreatePostRequest extends ModelTargetType<Post> with Authorized {
  final Uint8List imageBytes;
  final String title;
  final String body;

  CreatePostRequest({
    required this.imageBytes,
    required this.title,
    required this.body,
  }) : super(decoder: Post.fromJson);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => 'posts';

  @override
  RequestTask get requestTask => RequestTask.uploadMultipart({
    'image': MultipartFormDataData(
      data: imageBytes,
      fileName: 'post.jpg',
      mimeType: 'image/jpeg',
    ),
    'title': MultipartFormDataText(title),
    'body': MultipartFormDataText(body),
  });
}
```

---

## SSL Pinning

Enable SSL pinning per-request by overriding `sslPinningConfiguration` on your target request class.

```dart
final class GetSecureData extends ModelTargetType<SecurePayload> with Authorized {
  GetSecureData() : super(decoder: SecurePayload.fromJson);

  @override
  String get baseURL => AppApiTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => 'secure/data';

  @override
  SSLPinningConfiguration get sslPinningConfiguration =>
      const SSLPinningConfiguration(
        isEnabled: true,
        allowFallback: false,
        pinnedHosts: {'api.example.com'},
        pinnedCertificatePaths: ['assets/certs/api.example.com.der'],
        pinnedPublicKeyHashes: {'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='},
      );
}
```

Add your `.der` certificate to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/certs/api.example.com.der
```

---

## Logging

The layer logs all requests and responses in debug mode automatically. You can control it manually:

```dart
Logger.isEnabled = true;   // force on (e.g. during QA)
Logger.isEnabled = false;  // force off (e.g. in tests)
```

In release builds, logging defaults to `kDebugMode` (off).

---

## Network Connectivity

Check connectivity or react to changes before making requests:

```dart
// One-shot check
final isOnline = await NetworkMonitor.isConnected;
if (!isOnline) {
  // show offline banner
}

// Stream — react as connectivity changes
NetworkMonitor.onConnectivityChanged.listen((isConnected) {
  if (isConnected) syncPendingRequests();
});
```

The layer checks connectivity automatically before every request and throws `APIError(APIErrorType.noNetwork)` when offline — your client code receives it as a `Failure` in the `Result` type without any extra connectivity checks needed.
