import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('Result - Success', () {
    test('value returns the success value', () {
      const result = Success<int, String>(42);
      expect(result.value, 42);
    });

    test('error returns null for Success', () {
      const result = Success<int, String>(42);
      expect(result.error, isNull);
    });

    test('isSuccess is true', () {
      const result = Success<String, int>('ok');
      expect(result.isSuccess, isTrue);
    });

    test('isFailure is false', () {
      const result = Success<String, int>('ok');
      expect(result.isFailure, isFalse);
    });

    test('when calls success callback', () {
      const result = Success<int, String>(10);
      int? captured;
      result.when(
        success: (v) => captured = v,
        failure: (_) => captured = -1,
      );
      expect(captured, 10);
    });
  });

  group('Result - Failure', () {
    test('error returns the failure error', () {
      const result = Failure<int, String>('oops');
      expect(result.error, 'oops');
    });

    test('value returns null for Failure', () {
      const result = Failure<int, String>('oops');
      expect(result.value, isNull);
    });

    test('isFailure is true', () {
      const result = Failure<int, String>('err');
      expect(result.isFailure, isTrue);
    });

    test('isSuccess is false', () {
      const result = Failure<int, String>('err');
      expect(result.isSuccess, isFalse);
    });

    test('when calls failure callback', () {
      const result = Failure<int, String>('bad');
      String? captured;
      result.when(
        success: (_) => captured = 'should not reach',
        failure: (e) => captured = e,
      );
      expect(captured, 'bad');
    });
  });

  group('ResultMapping.map', () {
    test('transforms Success value', () {
      const result = Success<int, String>(5);
      final mapped = result.map((v) => v * 2);
      expect(mapped.value, 10);
      expect(mapped.isSuccess, isTrue);
    });

    test('passes Failure through unchanged', () {
      const result = Failure<int, String>('fail');
      final mapped = result.map((v) => v * 2);
      expect(mapped.error, 'fail');
      expect(mapped.isFailure, isTrue);
    });
  });

  group('ResultMapping.mapError', () {
    test('transforms Failure error', () {
      const result = Failure<int, String>('err');
      final mapped = result.mapError((e) => e.length);
      expect(mapped.error, 3);
      expect(mapped.isFailure, isTrue);
    });

    test('passes Success through unchanged', () {
      const result = Success<int, String>(7);
      final mapped = result.mapError((e) => e.length);
      expect(mapped.value, 7);
      expect(mapped.isSuccess, isTrue);
    });
  });

  group('Result type hierarchy', () {
    test('Success is a Result', () {
      const result = Success<int, String>(1);
      expect(result, isA<Result<int, String>>());
    });

    test('Failure is a Result', () {
      const result = Failure<int, String>('e');
      expect(result, isA<Result<int, String>>());
    });
  });
}
