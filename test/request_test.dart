import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

// Concrete TargetRequest for testing
class _TestTarget extends ModelTargetType<Map<String, dynamic>> {
  final String _base;
  final String _path;
  final HTTPMethod _method;
  final RequestType _type;
  final RequestTask _task;
  final Map<String, String> _headers;

  _TestTarget({
    String base = 'https://example.com/',
    String path = 'users',
    HTTPMethod method = HTTPMethod.get,
    RequestType type = RequestType.rest,
    RequestTask? task,
    Map<String, String> headers = const {},
  })  : _base = base,
        _path = path,
        _method = method,
        _type = type,
        _task = task ?? RequestTask.plain(),
        _headers = headers;

  @override
  String get baseURL => _base;
  @override
  String get requestPath => _path;
  @override
  HTTPMethod get requestMethod => _method;
  @override
  RequestType get requestType => _type;
  @override
  RequestTask get requestTask => _task;
  @override
  Map<String, String> get headers => _headers;
  @override
  Map<String, String> get authHeaders => const {};

  @override
  Map<String, dynamic> fromJson(Map<String, dynamic> json) => json;
}

void main() {
  group('createRequest - plain', () {
    test('creates GET request with correct URL', () async {
      final target = _TestTarget(base: 'https://api.example.com/', path: 'users');
      final request = await target.createRequest();
      expect(request.url.toString(), 'https://api.example.com/users');
      expect(request.method, 'GET');
    });

    test('includes merged headers', () async {
      final target = _TestTarget(headers: {'X-App-Version': '1.0'});
      final request = await target.createRequest();
      expect(request.headers['X-App-Version'], '1.0');
      expect(request.headers['Content-Type'], 'application/json');
    });
  });

  group('createRequest - parameters', () {
    test('appends string query parameters', () async {
      final target = _TestTarget(
        task: RequestTask.parameters({'page': 2, 'limit': 10}),
      );
      final request = await target.createRequest();
      expect(request.url.queryParameters['page'], '2');
      expect(request.url.queryParameters['limit'], '10');
    });

    test('handles list parameter values', () async {
      final target = _TestTarget(
        task: RequestTask.parameters({'ids': ['1', '2', '3']}),
      );
      final request = await target.createRequest();
      expect(request.url.queryParametersAll['ids'], ['1', '2', '3']);
    });

    test('handles null parameter value', () async {
      final target = _TestTarget(
        task: RequestTask.parameters({'id': null, 'page': 2}),
      );
      final request = await target.createRequest();
      expect(request.url.queryParameters['page'], '2');
    });

    test('preserves headers on the new request', () async {
      final target = _TestTarget(
        headers: {'X-Custom': 'val'},
        task: RequestTask.parameters({'q': 'test'}),
      );
      final request = await target.createRequest();
      expect(request.headers['X-Custom'], 'val');
    });
  });

  group('createRequest - encodedBody', () {
    test('encodes body as JSON', () async {
      final target = _TestTarget(
        method: HTTPMethod.post,
        task: RequestTask.encodedBody({'name': 'Alice', 'age': 30}),
      );
      final request = await target.createRequest() as http.Request;
      expect(request.headers['Content-Type'], 'application/json');
      expect(request.body, contains('"Alice"'));
    });

    test('sets Content-Length header', () async {
      final target = _TestTarget(
        method: HTTPMethod.post,
        task: RequestTask.encodedBody({'key': 'val'}),
      );
      final request = await target.createRequest() as http.Request;
      final length = int.parse(request.headers['Content-Length']!);
      expect(length, greaterThan(0));
    });

    test('throws APIError.dataConversionFailed for non-serializable object', () async {
      final target = _TestTarget(
        task: RequestTask.encodedBody(_NonSerializable()),
      );
      await expectLater(
        target.createRequest(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.dataConversionFailed,
        )),
      );
    });
  });

  group('createRequest - uploadFile', () {
    test('reads file and sets Content-Length', () async {
      final file = File('${Directory.systemTemp.path}/test_upload_req.bin');
      await file.writeAsBytes([1, 2, 3, 4, 5]);
      try {
        final target = _TestTarget(
          method: HTTPMethod.post,
          task: RequestTask.uploadFile(file.path),
        );
        final request = await target.createRequest() as http.Request;
        expect(request.bodyBytes, [1, 2, 3, 4, 5]);
        expect(request.headers['Content-Length'], '5');
      } finally {
        await file.delete();
      }
    });

    test('throws APIError.invalidURL when file does not exist', () async {
      final target = _TestTarget(
        task: RequestTask.uploadFile('/nonexistent/path/file.txt'),
      );
      await expectLater(
        target.createRequest(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.invalidURL,
        )),
      );
    });
  });

  group('createRequest - uploadMultipart', () {
    test('creates MultipartRequest with data field', () async {
      final fields = <String, MultipartFormData>{
        'avatar': MultipartFormDataData(
          data: Uint8List.fromList([0xFF, 0xD8]),
          fileName: 'photo.jpg',
          mimeType: 'image/jpeg',
        ),
      };
      final target = _TestTarget(
        method: HTTPMethod.post,
        task: RequestTask.uploadMultipart(fields),
      );
      final request = await target.createRequest();
      expect(request, isA<http.MultipartRequest>());
      final multi = request as http.MultipartRequest;
      expect(multi.files.any((f) => f.field == 'avatar'), isTrue);
    });

    test('creates MultipartRequest with text field', () async {
      final fields = <String, MultipartFormData>{
        'username': const MultipartFormDataText('alice'),
        'age': const MultipartFormDataText(25),
      };
      final target = _TestTarget(
        method: HTTPMethod.post,
        task: RequestTask.uploadMultipart(fields),
      );
      final request = await target.createRequest() as http.MultipartRequest;
      expect(request.fields['username'], 'alice');
      expect(request.fields['age'], '25');
    });

    test('copies request headers to multipart request', () async {
      final fields = <String, MultipartFormData>{
        'file': MultipartFormDataData(
          data: Uint8List(1),
          fileName: 'f.bin',
          mimeType: 'application/octet-stream',
        ),
      };
      final target = _TestTarget(
        method: HTTPMethod.post,
        headers: {'X-Token': 'abc'},
        task: RequestTask.uploadMultipart(fields),
      );
      final request = await target.createRequest() as http.MultipartRequest;
      expect(request.headers['X-Token'], 'abc');
    });
  });

  group('createRequest - download', () {
    test('creates plain GET request', () async {
      final target = _TestTarget(
        task: RequestTask.download('https://cdn.example.com/file.zip'),
      );
      final request = await target.createRequest();
      expect(request, isA<http.Request>());
      expect(request.method, 'GET');
    });
  });

  group('createRequest - downloadResumable', () {
    test('sets Range header when offset is provided', () async {
      final target = _TestTarget(
        task: RequestTask.downloadResumable(offset: 2048),
      );
      final request = await target.createRequest() as http.Request;
      expect(request.headers['Range'], 'bytes=2048-');
    });

    test('does not set Range header when offset is null', () async {
      final target = _TestTarget(
        task: RequestTask.downloadResumable(),
      );
      final request = await target.createRequest() as http.Request;
      expect(request.headers.containsKey('Range'), isFalse);
    });
  });

  group('createRequest - parametersAndBody', () {
    test('adds both query params and JSON body', () async {
      final target = _TestTarget(
        method: HTTPMethod.post,
        task: RequestTask.parametersAndBody({'page': 1}, {'filter': 'active'}),
      );
      final request = await target.createRequest() as http.Request;
      expect(request.url.queryParameters['page'], '1');
      expect(request.body, contains('"filter"'));
    });

    test('works with null body', () async {
      final target = _TestTarget(
        method: HTTPMethod.post,
        task: RequestTask.parametersAndBody({'q': 'search'}, null),
      );
      final request = await target.createRequest() as http.Request;
      expect(request.url.queryParameters['q'], 'search');
      expect(request.body, isEmpty);
    });

    test('throws dataConversionFailed for non-serializable body', () async {
      final target = _TestTarget(
        task: RequestTask.parametersAndBody({'p': 1}, _NonSerializable()),
      );
      await expectLater(
        target.createRequest(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.dataConversionFailed,
        )),
      );
    });
  });

  group('createRequest - SOAP', () {
    test('throws notSupportedSOAPOperation', () async {
      final target = _TestTarget(type: RequestType.soap);
      await expectLater(
        target.createRequest(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.notSupportedSOAPOperation,
        )),
      );
    });
  });

  group('createRequest - invalid URL', () {
    test('throws APIError.invalidURL for malformed base URL', () async {
      final target = _TestTarget(base: '://bad', path: 'test');
      await expectLater(
        target.createRequest(),
        throwsA(isA<APIError>()),
      );
    });
  });
}

class _NonSerializable {
  @override
  String toString() => 'NonSerializable';
}
