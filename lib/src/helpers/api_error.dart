import 'enums.dart';

/// Enum representing API error categories for comprehensive error handling
enum APIErrorType {
  /// The request URL could not be formed or resolved.
  invalidURL,

  /// The response data could not be decoded into the expected model.
  dataConversionFailed,

  /// A string encoding or decoding step failed.
  stringConversionFailed,

  /// The server returned a non-2xx HTTP status code.
  httpError,

  /// A SOAP multipart request was malformed.
  invalidSoapMultipartRequest,

  /// XML encoding of the request body failed.
  xmlEncodingFailed,

  /// The requested SOAP operation is not supported.
  notSupportedSOAPOperation,

  /// No internet connection was available when the request was attempted.
  noNetwork,

  /// The server response could not be interpreted.
  invalidResponse,
}

/// Represents a network error with a category, optional HTTP status code,
/// and an optional decoded error payload from the server.
class APIError implements Exception {
  /// The broad category of the error.
  final APIErrorType type;

  /// The HTTP status code category returned by the server, if applicable.
  final HTTPStatusCode? statusCode;

  /// An optional decoded error payload attached by [APIErrorResponseMapper].
  ///
  /// Cast to your app's error model to read server-provided error details.
  final dynamic errorModel;

  /// Creates an [APIError] with the given [type] and optional [statusCode]
  /// and [errorModel].
  const APIError(this.type, {this.statusCode, this.errorModel});

  /// Returns [errorModel] cast to [T], or null if the cast fails or [errorModel] is null.
  T? errorModelAs<T>() => errorModel as T?;

  @override
  String toString() {
    final baseMessage = _baseMessage();
    if (errorModel != null) {
      return '$baseMessage (Error Data: $errorModel)';
    }
    return baseMessage;
  }

  String _baseMessage() {
    switch (type) {
      case APIErrorType.invalidURL:
        return 'Invalid URL formation.';
      case APIErrorType.dataConversionFailed:
        return 'Failed to convert data.';
      case APIErrorType.stringConversionFailed:
        return 'Failed to convert string.';
      case APIErrorType.httpError:
        return 'HTTP Error with status code: $statusCode';
      case APIErrorType.invalidSoapMultipartRequest:
        return 'Invalid SOAP multipart request.';
      case APIErrorType.xmlEncodingFailed:
        return 'XML encoding failed.';
      case APIErrorType.notSupportedSOAPOperation:
        return 'SOAP operation not supported.';
      case APIErrorType.noNetwork:
        return 'No internet connection.';
      case APIErrorType.invalidResponse:
        return 'Invalid response.';
    }
  }
}
