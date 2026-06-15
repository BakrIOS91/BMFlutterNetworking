import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/src/helpers/enums.dart';
import '../interceptor.dart';

/// Interceptor that handles 401 Unauthorized responses by attempting a token refresh.
class AuthInterceptor extends NetworkInterceptor {
  final bool isAuthorized;
  final Future<http.BaseRequest> Function() refreshRequest;
  final Future<http.StreamedResponse> Function(http.BaseRequest) retry;

  bool _isRetrying = false;

  AuthInterceptor({
    required this.isAuthorized,
    required this.refreshRequest,
    required this.retry,
  });

  @override
  FutureOr<http.StreamedResponse> onResponse(
      http.BaseRequest request, http.StreamedResponse response) async {
    final statusCategory = HTTPStatusCode.from(response.statusCode);

    if (statusCategory == HTTPStatusCode.notAuthorize &&
        isAuthorized &&
        !_isRetrying) {
      _isRetrying = true;
      try {
        final newRequest = await refreshRequest();
        return await retry(newRequest);
      } catch (_) {
        return response;
      }
    }

    return response;
  }
}
