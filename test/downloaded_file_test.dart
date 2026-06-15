import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('DownloadedFile', () {
    test('toJson with URLs serializes correctly', () {
      final file = DownloadedFile(
        downloadedUrl: Uri.parse('file:///tmp/test.jpg'),
        remoteUrl: Uri.parse('https://example.com/test.jpg'),
      );
      final json = file.toJson();
      expect(json['downloadedUrl'], 'file:///tmp/test.jpg');
      expect(json['remoteUrl'], 'https://example.com/test.jpg');
    });

    test('toJson with null URLs serializes as null', () {
      const file = DownloadedFile();
      final json = file.toJson();
      expect(json['downloadedUrl'], isNull);
      expect(json['remoteUrl'], isNull);
    });

    test('stores all fields', () {
      final downloadedUrl = Uri.parse('file:///tmp/file.pdf');
      final remoteUrl = Uri.parse('https://api.example.com/files/1');
      final file = DownloadedFile(
        downloadedUrl: downloadedUrl,
        remoteUrl: remoteUrl,
      );
      expect(file.downloadedUrl, downloadedUrl);
      expect(file.remoteUrl, remoteUrl);
    });

    test('response field is nullable', () {
      const file = DownloadedFile();
      expect(file.response, isNull);
    });

    test('toJson does not include response key', () {
      const file = DownloadedFile();
      final json = file.toJson();
      expect(json.containsKey('response'), isFalse);
    });
  });
}
