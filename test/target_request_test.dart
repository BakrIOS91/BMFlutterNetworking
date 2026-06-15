import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

// Minimal concrete SuccessTargetType for testing
class _TestSuccess extends SuccessTargetType {
  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => '/users';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
}

// SuccessTargetType with custom headers
class _HeaderSuccess extends SuccessTargetType {
  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => '/data';
  @override
  HTTPMethod get requestMethod => HTTPMethod.post;
  @override
  Map<String, String> get headers => {'X-Custom': 'value'};
  @override
  Map<String, String> get authHeaders => {'Authorization': 'Bearer token'};
}

// ModelTargetType with overridden fromJson
class _TestModel {
  final String name;
  _TestModel(this.name);
}

class _OverrideTarget extends ModelTargetType<_TestModel> {
  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => '/models';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
  @override
  _TestModel fromJson(Map<String, dynamic> json) => _TestModel(json['name']);
}

// ModelTargetType with constructor decoder
class _DecoderTarget extends ModelTargetType<_TestModel> {
  _DecoderTarget()
      : super(decoder: (json) => _TestModel('decoded_${json['name']}'));
  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => '/models';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
}

// ModelTargetType with neither decoder nor override - should throw
class _BrokenTarget extends ModelTargetType<_TestModel> {
  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => '/broken';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
}

void main() {
  group('SuccessTargetType defaults', () {
    test('requestType defaults to rest', () {
      final target = _TestSuccess();
      expect(target.requestType, RequestType.rest);
    });

    test('isAuthorized defaults to false', () {
      final target = _TestSuccess();
      expect(target.isAuthorized, isFalse);
    });

    test('headers defaults to empty map', () {
      final target = _TestSuccess();
      expect(target.headers, isEmpty);
    });

    test('authHeaders defaults to empty map', () {
      final target = _TestSuccess();
      expect(target.authHeaders, isEmpty);
    });

    test('requestTask defaults to plain', () {
      final target = _TestSuccess();
      expect(target.requestTask.type, RequestTaskType.plain);
    });

    test('sslPinningConfiguration defaults to null', () {
      final target = _TestSuccess();
      expect(target.sslPinningConfiguration, isNull);
    });

    test('useUniqueFilename defaults to false', () {
      final target = _TestSuccess();
      expect(target.useUniqueFilename, isFalse);
    });
  });

  group('TargetRequest.defaultHeaders', () {
    test('contains Content-Type application/json', () {
      final target = _TestSuccess();
      expect(target.defaultHeaders['Content-Type'], 'application/json');
    });

    test('contains Accept */*', () {
      final target = _TestSuccess();
      expect(target.defaultHeaders['Accept'], '*/*');
    });
  });

  group('TargetRequest.mergedHeaders', () {
    test('merged headers include default headers', () {
      final target = _TestSuccess();
      expect(target.mergedHeaders['Content-Type'], 'application/json');
      expect(target.mergedHeaders['Accept'], '*/*');
    });

    test('custom headers override defaults', () {
      // Create target where custom header overrides Content-Type
      final target = _HeaderSuccess();
      // headers + authHeaders are merged over defaults
      expect(target.mergedHeaders['X-Custom'], 'value');
      expect(target.mergedHeaders['Authorization'], 'Bearer token');
    });

    test('authHeaders are included', () {
      final target = _HeaderSuccess();
      expect(target.mergedHeaders['Authorization'], 'Bearer token');
    });
  });

  group('TargetRequest.requestTaskDescription', () {
    test('plain task description', () {
      final target = _TestSuccess();
      expect(target.requestTaskDescription, 'Plain request');
    });
  });

  group('TargetRequest.requestTaskDescription via ModelTargetType', () {
    // We test requestTaskDescription via a target that overrides requestTask

    test('parameters task description', () {
      final target = _DescriptionTarget(RequestTask.parameters({'q': 'search'}));
      expect(target.requestTaskDescription, contains('Parameters:'));
      expect(target.requestTaskDescription, contains('q'));
    });

    test('encodedBody task description', () {
      final target = _DescriptionTarget(RequestTask.encodedBody({'key': 'val'}));
      expect(target.requestTaskDescription, contains('Body:'));
    });

    test('uploadFile task description', () {
      final target = _DescriptionTarget(RequestTask.uploadFile('/tmp/file.jpg'));
      expect(target.requestTaskDescription, contains('Upload file:'));
    });

    test('uploadMultipart task description', () {
      final target = _DescriptionTarget(
        RequestTask.uploadMultipart({'file': const MultipartFormDataText('data')}),
      );
      expect(target.requestTaskDescription, contains('Multipart fields:'));
    });

    test('download task description', () {
      final target = _DescriptionTarget(RequestTask.download('https://cdn.example.com/file.zip'));
      expect(target.requestTaskDescription, contains('Download from:'));
    });

    test('downloadResumable task description', () {
      final target = _DescriptionTarget(RequestTask.downloadResumable(offset: 512));
      expect(target.requestTaskDescription, contains('Resumable download with offset:'));
    });

    test('parametersAndBody task description', () {
      final target = _DescriptionTarget(
        RequestTask.parametersAndBody({'page': 1}, {'filter': 'active'}),
      );
      expect(target.requestTaskDescription, contains('Parameters:'));
      expect(target.requestTaskDescription, contains('Body:'));
    });
  });

  group('ModelTargetType defaults', () {
    test('isAuthorized defaults to false', () {
      expect(_OverrideTarget().isAuthorized, isFalse);
    });

    test('headers defaults to empty map', () {
      expect(_OverrideTarget().headers, isEmpty);
    });

    test('authHeaders defaults to empty map', () {
      expect(_OverrideTarget().authHeaders, isEmpty);
    });

    test('requestTask defaults to plain', () {
      expect(_OverrideTarget().requestTask.type, RequestTaskType.plain);
    });

    test('sslPinningConfiguration defaults to null', () {
      expect(_OverrideTarget().sslPinningConfiguration, isNull);
    });

    test('requestType defaults to rest', () {
      expect(_OverrideTarget().requestType, RequestType.rest);
    });
  });

  group('ModelTargetType.fromJson', () {
    test('uses overridden fromJson when no decoder provided', () {
      final target = _OverrideTarget();
      final model = target.fromJson({'name': 'Alice'});
      expect(model.name, 'Alice');
    });

    test('uses constructor decoder when provided', () {
      final target = _DecoderTarget();
      final model = target.fromJson({'name': 'Bob'});
      expect(model.name, 'decoded_Bob');
    });

    test('throws UnimplementedError when neither decoder nor override', () {
      final target = _BrokenTarget();
      expect(
        () => target.fromJson({'name': 'test'}),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}

// Helper target that overrides requestTask for description tests
class _DescriptionTarget extends ModelTargetType<_TestModel> {
  final RequestTask _task;

  _DescriptionTarget(this._task);

  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => '/test';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
  @override
  RequestTask get requestTask => _task;
  @override
  _TestModel fromJson(Map<String, dynamic> json) => _TestModel(json['name']);
}
