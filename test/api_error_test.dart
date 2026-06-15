import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('APIError.toString', () {
    test('invalidURL', () {
      const error = APIError(APIErrorType.invalidURL);
      expect(error.toString(), 'Invalid URL formation.');
    });

    test('dataConversionFailed', () {
      const error = APIError(APIErrorType.dataConversionFailed);
      expect(error.toString(), 'Failed to convert data.');
    });

    test('stringConversionFailed', () {
      const error = APIError(APIErrorType.stringConversionFailed);
      expect(error.toString(), 'Failed to convert string.');
    });

    test('httpError without status code', () {
      const error = APIError(APIErrorType.httpError);
      expect(error.toString(), contains('HTTP Error with status code:'));
    });

    test('httpError with status code', () {
      const error = APIError(
        APIErrorType.httpError,
        statusCode: HTTPStatusCode.notAuthorize,
      );
      expect(error.toString(),
          'HTTP Error with status code: HTTPStatusCode.notAuthorize');
    });

    test('invalidSoapMultipartRequest', () {
      const error = APIError(APIErrorType.invalidSoapMultipartRequest);
      expect(error.toString(), 'Invalid SOAP multipart request.');
    });

    test('xmlEncodingFailed', () {
      const error = APIError(APIErrorType.xmlEncodingFailed);
      expect(error.toString(), 'XML encoding failed.');
    });

    test('notSupportedSOAPOperation', () {
      const error = APIError(APIErrorType.notSupportedSOAPOperation);
      expect(error.toString(), 'SOAP operation not supported.');
    });

    test('noNetwork', () {
      const error = APIError(APIErrorType.noNetwork);
      expect(error.toString(), 'No internet connection.');
    });

    test('invalidResponse', () {
      const error = APIError(APIErrorType.invalidResponse);
      expect(error.toString(), 'Invalid response.');
    });

    test('appends errorModel when present', () {
      final error = APIError(
        APIErrorType.httpError,
        statusCode: HTTPStatusCode.clientError,
        errorModel: {'message': 'bad request'},
      );
      expect(error.toString(), contains('Error Data:'));
      expect(error.toString(), contains('bad request'));
    });

    test('does not append errorModel when null', () {
      const error = APIError(APIErrorType.noNetwork);
      expect(error.toString(), isNot(contains('Error Data:')));
    });
  });

  group('APIError fields', () {
    test('stores type', () {
      const error = APIError(APIErrorType.noNetwork);
      expect(error.type, APIErrorType.noNetwork);
    });

    test('stores statusCode', () {
      const error = APIError(
        APIErrorType.httpError,
        statusCode: HTTPStatusCode.serverError,
      );
      expect(error.statusCode, HTTPStatusCode.serverError);
    });

    test('stores errorModel', () {
      const errorModel = 'some model';
      const error = APIError(APIErrorType.httpError, errorModel: errorModel);
      expect(error.errorModel, errorModel);
    });

    test('implements Exception', () {
      const error = APIError(APIErrorType.noNetwork);
      expect(error, isA<Exception>());
    });
  });
}
