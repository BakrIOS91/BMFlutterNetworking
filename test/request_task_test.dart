import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('RequestTask factories', () {
    test('plain() creates plain task', () {
      final task = RequestTask.plain();
      expect(task.type, RequestTaskType.plain);
      expect(task.parameters, isNull);
      expect(task.body, isNull);
      expect(task.filePath, isNull);
      expect(task.fields, isNull);
      expect(task.url, isNull);
      expect(task.resumeData, isNull);
      expect(task.offset, isNull);
    });

    test('parameters() stores params', () {
      final task = RequestTask.parameters({'page': 1, 'limit': 20});
      expect(task.type, RequestTaskType.parameters);
      expect(task.parameters, {'page': 1, 'limit': 20});
    });

    test('encodedBody() stores body', () {
      final body = {'name': 'Alice', 'age': 30};
      final task = RequestTask.encodedBody(body);
      expect(task.type, RequestTaskType.encodedBody);
      expect(task.body, body);
    });

    test('uploadFile() stores filePath', () {
      final task = RequestTask.uploadFile('/tmp/photo.jpg');
      expect(task.type, RequestTaskType.uploadFile);
      expect(task.filePath, '/tmp/photo.jpg');
    });

    test('uploadMultipart() stores fields', () {
      final fields = <String, MultipartFormData>{
        'avatar': MultipartFormDataData(
          data: Uint8List.fromList([1, 2, 3]),
          fileName: 'avatar.png',
          mimeType: 'image/png',
        ),
        'name': const MultipartFormDataText('Alice'),
      };
      final task = RequestTask.uploadMultipart(fields);
      expect(task.type, RequestTaskType.uploadMultipart);
      expect(task.fields, fields);
    });

    test('download() stores url', () {
      final task = RequestTask.download('https://example.com/file.zip');
      expect(task.type, RequestTaskType.download);
      expect(task.url, 'https://example.com/file.zip');
    });

    test('downloadResumable() with both resumeData and offset', () {
      final resumeData = Uint8List.fromList([10, 20, 30]);
      final task = RequestTask.downloadResumable(
        resumeData: resumeData,
        offset: 1024,
      );
      expect(task.type, RequestTaskType.downloadResumable);
      expect(task.resumeData, resumeData);
      expect(task.offset, 1024);
    });

    test('downloadResumable() without arguments', () {
      final task = RequestTask.downloadResumable();
      expect(task.type, RequestTaskType.downloadResumable);
      expect(task.resumeData, isNull);
      expect(task.offset, isNull);
    });

    test('parametersAndBody() stores both params and body', () {
      final params = {'q': 'search'};
      final body = {'filter': 'active'};
      final task = RequestTask.parametersAndBody(params, body);
      expect(task.type, RequestTaskType.parametersAndBody);
      expect(task.parameters, params);
      expect(task.body, body);
    });
  });
}
