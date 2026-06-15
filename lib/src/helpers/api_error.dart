import 'enums.dart';

/// Enum representing API error categories for comprehensive error handling
enum APIErrorType {
  invalidURL,
  dataConversionFailed,
  stringConversionFailed,
  httpError,
  invalidSoapMultipartRequest,
  xmlEncodingFailed,
  notSupportedSOAPOperation,
  noNetwork,
  invalidResponse,
}

/// Represents different types of network-related errors with detailed information
class APIError implements Exception {
  final APIErrorType type;
  final HTTPStatusCode? statusCode;
  final dynamic errorModel;

  const APIError(this.type, {this.statusCode, this.errorModel});

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
