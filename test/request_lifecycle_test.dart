import 'dart:async';
import 'dart:convert';

import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:bm_flutter_networking/src/network/core/request_guard.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _channel = MethodChannel('dev.fluttercommunity.plus/connectivity');

void _online() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, (call) async => ['wifi']);
}

class _Target extends SuccessTargetType {
  _Target({this.method = HTTPMethod.get, this.timeouts = false});
  final HTTPMethod method;
  final bool timeouts;

  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => 'thing';
  @override
  HTTPMethod get requestMethod => method;
  @override
  Duration? get sendTimeout =>
      timeouts ? const Duration(milliseconds: 50) : null;
  @override
  Duration? get receiveTimeout =>
      timeouts ? const Duration(milliseconds: 50) : null;
  @override
  RequestTask get requestTask => method == HTTPMethod.get
      ? RequestTask.plain()
      : RequestTask.encodedBody({'a': 1});
}

APIErrorType? _typeOf(Object? e) => e is APIError ? e.type : null;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(_online);
  tearDown(() {
    NetworkConfig.reset();
    RequestGuard.connectivityProvider = () => const Stream.empty();
  });

  // A server that never answers.
  http.Client hang() => MockClient((_) => Completer<http.Response>().future);

  test('cancel token aborts an in-flight request', () async {
    final token = CancelToken();
    final future = http.runWithClient(
      () => _Target().performAsync(cancelToken: token),
      hang,
    );
    Timer(const Duration(milliseconds: 20), token.cancel);
    await expectLater(
      future,
      throwsA(predicate((e) => _typeOf(e) == APIErrorType.cancelled)),
    );
  });

  test('an already cancelled token never sends the request', () async {
    var sent = false;
    final token = CancelToken()..cancel();
    await expectLater(
      http.runWithClient(
        () => _Target().performAsync(cancelToken: token),
        () => MockClient((_) async {
          sent = true;
          return http.Response('{}', 200);
        }),
      ),
      throwsA(predicate((e) => _typeOf(e) == APIErrorType.cancelled)),
    );
    expect(sent, isFalse);
  });

  test('send timeout surfaces APIErrorType.timeout', () async {
    await expectLater(
      http.runWithClient(
        () => _Target(timeouts: true).performAsync(),
        hang,
      ),
      throwsA(predicate((e) => _typeOf(e) == APIErrorType.timeout)),
    );
  });

  test('global timeout applies when the endpoint does not override it',
      () async {
    NetworkConfig.configure(sendTimeout: const Duration(milliseconds: 50));
    await expectLater(
      http.runWithClient(() => _Target().performAsync(), hang),
      throwsA(predicate((e) => _typeOf(e) == APIErrorType.timeout)),
    );
  });

  group('connection lost while in flight', () {
    test('GET -> noNetwork', () async {
      final online = StreamController<bool>();
      RequestGuard.connectivityProvider = () => online.stream;
      final future = http.runWithClient(() => _Target().performAsync(), hang);
      Timer(const Duration(milliseconds: 20), () => online.add(false));
      await expectLater(
        future,
        throwsA(predicate((e) => _typeOf(e) == APIErrorType.noNetwork)),
      );
    });

    test('POST -> connectionLostDuringRequest and is not retried', () async {
      final online = StreamController<bool>();
      RequestGuard.connectivityProvider = () => online.stream;
      var calls = 0;
      final future = http.runWithClient(
        () => _Target(method: HTTPMethod.post).performAsync(),
        () => MockClient((_) {
          calls++;
          return Completer<http.Response>().future;
        }),
      );
      Timer(const Duration(milliseconds: 20), () => online.add(false));
      await expectLater(
        future,
        throwsA(predicate(
            (e) => _typeOf(e) == APIErrorType.connectionLostDuringRequest)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(calls, 1);
    });

    test('regaining connectivity does not abort', () async {
      final online = StreamController<bool>();
      RequestGuard.connectivityProvider = () => online.stream;
      final future = http.runWithClient(
        () => _Target().performAsync(),
        () => MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response(jsonEncode({}), 200);
        }),
      );
      online.add(true);
      await future;
    });
  });
}
