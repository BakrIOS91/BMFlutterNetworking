// Tests the web stub implementations directly by importing the web-specific
// files. These tests run on the native VM but exercise the web code paths.
import 'package:flutter_test/flutter_test.dart';

import 'package:bm_flutter_networking/src/platform/file_io_web.dart'
    as file_io_web;
import 'package:bm_flutter_networking/src/network/core/ssl_pinning_helper_web.dart'
    as ssl_web;
import 'package:bm_flutter_networking/src/network/core/ssl_pinning.dart';

void main() {
  group('file_io_web stubs', () {
    test('readFileBytesFromPath throws UnsupportedError', () async {
      await expectLater(
        file_io_web.readFileBytesFromPath('any/path.txt'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('saveStreamToTemp throws UnsupportedError', () async {
      await expectLater(
        file_io_web.saveStreamToTemp('file.bin', Stream.empty()),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('SSLPinningHelper web stub', () {
    test('constructor accepts SSLPinningConfiguration', () {
      const config = SSLPinningConfiguration(isEnabled: false);
      final helper = ssl_web.SSLPinningHelper(configuration: config);
      expect(helper.configuration, config);
    });

    test('createSecureHttpClient throws UnsupportedError', () async {
      const config = SSLPinningConfiguration(isEnabled: true);
      final helper = ssl_web.SSLPinningHelper(configuration: config);
      await expectLater(
        helper.createSecureHttpClient(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
