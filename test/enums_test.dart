import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('AppEnvironment', () {
    test('has five values', () {
      expect(AppEnvironment.values.length, 5);
    });
  });

  group('AppEnvironmentEnv.fromString', () {
    test('parses development variants', () {
      expect(AppEnvironmentEnv.fromString('development'), AppEnvironment.development);
      expect(AppEnvironmentEnv.fromString('dev'), AppEnvironment.development);
      expect(AppEnvironmentEnv.fromString('DEVELOPMENT'), AppEnvironment.development);
      expect(AppEnvironmentEnv.fromString('DEV'), AppEnvironment.development);
    });

    test('parses testing variants', () {
      expect(AppEnvironmentEnv.fromString('testing'), AppEnvironment.testing);
      expect(AppEnvironmentEnv.fromString('test'), AppEnvironment.testing);
    });

    test('parses staging', () {
      expect(AppEnvironmentEnv.fromString('staging'), AppEnvironment.staging);
      expect(AppEnvironmentEnv.fromString('STAGING'), AppEnvironment.staging);
    });

    test('parses preProduction variants', () {
      expect(AppEnvironmentEnv.fromString('preproduction'), AppEnvironment.preProduction);
      expect(AppEnvironmentEnv.fromString('pre_production'), AppEnvironment.preProduction);
      expect(AppEnvironmentEnv.fromString('pre-production'), AppEnvironment.preProduction);
      expect(AppEnvironmentEnv.fromString('preprod'), AppEnvironment.preProduction);
      expect(AppEnvironmentEnv.fromString('PREPROD'), AppEnvironment.preProduction);
    });

    test('parses production variants', () {
      expect(AppEnvironmentEnv.fromString('production'), AppEnvironment.production);
      expect(AppEnvironmentEnv.fromString('prod'), AppEnvironment.production);
      expect(AppEnvironmentEnv.fromString('PROD'), AppEnvironment.production);
    });

    test('defaults to development for unknown value', () {
      expect(AppEnvironmentEnv.fromString('unknown'), AppEnvironment.development);
      expect(AppEnvironmentEnv.fromString(''), AppEnvironment.development);
      expect(AppEnvironmentEnv.fromString('xyz'), AppEnvironment.development);
    });
  });

  group('HTTPMethod value extension', () {
    test('returns uppercase name for each method', () {
      expect(HTTPMethod.get.value, 'GET');
      expect(HTTPMethod.post.value, 'POST');
      expect(HTTPMethod.put.value, 'PUT');
      expect(HTTPMethod.delete.value, 'DELETE');
      expect(HTTPMethod.patch.value, 'PATCH');
      expect(HTTPMethod.head.value, 'HEAD');
      expect(HTTPMethod.options.value, 'OPTIONS');
      expect(HTTPMethod.trace.value, 'TRACE');
      expect(HTTPMethod.connect.value, 'CONNECT');
    });
  });

  group('MultipartFormData', () {
    test('MultipartFormDataData stores all properties', () {
      final data = MultipartFormDataData(
        data: Uint8List.fromList([1, 2, 3]),
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
      );
      expect(data.data, [1, 2, 3]);
      expect(data.fileName, 'test.jpg');
      expect(data.mimeType, 'image/jpeg');
    });

    test('MultipartFormDataText stores string value', () {
      const text = MultipartFormDataText('hello');
      expect(text.value, 'hello');
    });

    test('MultipartFormDataText stores numeric value', () {
      const text = MultipartFormDataText(42);
      expect(text.value, 42);
    });

    test('MultipartFormDataText stores null value', () {
      const text = MultipartFormDataText(null);
      expect(text.value, isNull);
    });

    test('subtypes are instances of MultipartFormData', () {
      final data = MultipartFormDataData(
        data: Uint8List(0),
        fileName: 'f',
        mimeType: 'application/octet-stream',
      );
      const text = MultipartFormDataText('v');
      expect(data, isA<MultipartFormData>());
      expect(text, isA<MultipartFormData>());
    });
  });

  group('HTTPStatusCode.from', () {
    test('1xx returns information', () {
      expect(HTTPStatusCode.from(100), HTTPStatusCode.information);
      expect(HTTPStatusCode.from(150), HTTPStatusCode.information);
      expect(HTTPStatusCode.from(199), HTTPStatusCode.information);
    });

    test('2xx returns success', () {
      expect(HTTPStatusCode.from(200), HTTPStatusCode.success);
      expect(HTTPStatusCode.from(201), HTTPStatusCode.success);
      expect(HTTPStatusCode.from(299), HTTPStatusCode.success);
    });

    test('3xx returns redirection', () {
      expect(HTTPStatusCode.from(300), HTTPStatusCode.redirection);
      expect(HTTPStatusCode.from(301), HTTPStatusCode.redirection);
      expect(HTTPStatusCode.from(399), HTTPStatusCode.redirection);
    });

    test('401 returns notAuthorize', () {
      expect(HTTPStatusCode.from(401), HTTPStatusCode.notAuthorize);
    });

    test('404 returns notFound', () {
      expect(HTTPStatusCode.from(404), HTTPStatusCode.notFound);
    });

    test('4xx (except 401 and 404) returns clientError', () {
      expect(HTTPStatusCode.from(400), HTTPStatusCode.clientError);
      expect(HTTPStatusCode.from(403), HTTPStatusCode.clientError);
      expect(HTTPStatusCode.from(422), HTTPStatusCode.clientError);
      expect(HTTPStatusCode.from(499), HTTPStatusCode.clientError);
    });

    test('5xx returns serverError', () {
      expect(HTTPStatusCode.from(500), HTTPStatusCode.serverError);
      expect(HTTPStatusCode.from(503), HTTPStatusCode.serverError);
      expect(HTTPStatusCode.from(599), HTTPStatusCode.serverError);
    });

    test('out-of-range codes return unknown', () {
      expect(HTTPStatusCode.from(0), HTTPStatusCode.unknown);
      expect(HTTPStatusCode.from(99), HTTPStatusCode.unknown);
      expect(HTTPStatusCode.from(600), HTTPStatusCode.unknown);
      expect(HTTPStatusCode.from(999), HTTPStatusCode.unknown);
    });
  });

  group('SupportedLocale', () {
    test('locale without country code returns single-part Locale', () {
      final locale = SupportedLocale.en.locale;
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, isNull);
    });

    test('locale with country code returns two-part Locale', () {
      final locale = SupportedLocale.enUs.locale;
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, 'US');
    });

    test('Arabic locale without country code', () {
      expect(SupportedLocale.ar.locale.languageCode, 'ar');
      expect(SupportedLocale.ar.locale.countryCode, isNull);
    });

    test('Arabic locale with country code', () {
      final locale = SupportedLocale.arSA.locale;
      expect(locale.languageCode, 'ar');
      expect(locale.countryCode, 'SA');
    });

    test('Chinese locale', () {
      final locale = SupportedLocale.zhCn.locale;
      expect(locale.languageCode, 'zh');
      expect(locale.countryCode, 'CN');
    });

    test('rawValue is correctly stored', () {
      expect(SupportedLocale.ar.rawValue, 'ar');
      expect(SupportedLocale.enUs.rawValue, 'en_US');
      expect(SupportedLocale.zhCn.rawValue, 'zh_CN');
      expect(SupportedLocale.zhHk.rawValue, 'zh_HK');
      expect(SupportedLocale.zhTw.rawValue, 'zh_TW');
    });

    test('German locales are correct', () {
      expect(SupportedLocale.de.locale.languageCode, 'de');
      expect(SupportedLocale.deDe.locale.countryCode, 'DE');
    });
  });

  group('RequestType', () {
    test('has rest and soap', () {
      expect(RequestType.values, contains(RequestType.rest));
      expect(RequestType.values, contains(RequestType.soap));
    });
  });

  group('RequestTaskType', () {
    test('has eight values', () {
      expect(RequestTaskType.values.length, 8);
    });

    test('contains expected values', () {
      expect(RequestTaskType.values, containsAll([
        RequestTaskType.plain,
        RequestTaskType.parameters,
        RequestTaskType.encodedBody,
        RequestTaskType.uploadFile,
        RequestTaskType.uploadMultipart,
        RequestTaskType.download,
        RequestTaskType.downloadResumable,
        RequestTaskType.parametersAndBody,
      ]));
    });
  });
}
