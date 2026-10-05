import 'dart:async';

import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:bm_flutter_networking/src/network/core/network_monitor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _FakeChannel extends StreamChannelMixin<dynamic>
    implements WebSocketChannel {
  final _incoming = StreamController<dynamic>();
  final sent = <dynamic>[];
  final _ready = Completer<void>();
  int? _closeCode;
  late final _sink = _FakeSink(this);

  void open() => _ready.complete();
  void failToOpen() => _ready.completeError(Exception('refused'));
  void push(dynamic m) => _incoming.add(m);
  void serverClose(int code) {
    _closeCode = code;
    _incoming.close();
  }

  @override
  Future<void> get ready => _ready.future;
  @override
  Stream<dynamic> get stream => _incoming.stream;
  @override
  WebSocketSink get sink => _sink;
  @override
  int? get closeCode => _closeCode;
  @override
  String? get closeReason => null;
  @override
  String? get protocol => null;
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this.channel);
  final _FakeChannel channel;
  @override
  void add(dynamic data) => channel.sent.add(data);
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<dynamic> stream) => stream.forEach(add);
  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    channel._closeCode ??= closeCode;
  }

  @override
  Future<void> get done async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<_FakeChannel> channels;
  late List<Uri> uris;
  late List<Map<String, String>> handshakes;
  var token = 'token-1';

  BMWebSocketClient build({
    bool Function()? shouldReconnect,
    ReconnectPolicy policy = const ReconnectPolicy.fixed(
      Duration(milliseconds: 10),
    ),
  }) =>
      BMWebSocketClient(
        url: Uri.parse('wss://example.com/api/v2/ranger/private/'),
        streams: ['global.currencies_prices', 'global.currencies_data'],
        accessToken: () async => token,
        headers: {'User-Agent': 'MKX'},
        reconnectPolicy: policy,
        refreshTokenOnReconnect: false,
        reconnectOnConnectivityRegained: false,
        shouldReconnect: shouldReconnect,
        connector: (uri, headers) {
          uris.add(uri);
          handshakes.add(headers);
          final c = _FakeChannel();
          channels.add(c);
          return c;
        },
      );

  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 40));

  setUp(() {
    channels = [];
    uris = [];
    handshakes = [];
    token = 'token-1';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (_) async => ['wifi'],
    );
  });

  tearDown(BMWebSocketRegistry.closeAll);

  test('opens one URL with repeated stream params and auth headers', () async {
    final client = build();
    unawaited(client.connect());
    await pump();
    channels.single.open();
    await pump();

    expect(
      uris.single.toString(),
      'wss://example.com/api/v2/ranger/private/'
      '?stream=global.currencies_prices&stream=global.currencies_data',
    );
    expect(handshakes.single['Authorization'], 'Bearer token-1');
    expect(handshakes.single['User-Agent'], 'MKX');
    expect(client.state, SocketConnectionState.open);
    await client.close();
  });

  test('delivers messages as a stream and decodes JSON', () async {
    final client = build();
    final raw = <dynamic>[];
    final json = <Object?>[];
    client.messages.listen(raw.add);
    client.jsonMessages.listen(json.add);
    unawaited(client.connect());
    await pump();
    channels.single
      ..open()
      ..push('{"a":1}')
      ..push('not json');
    await pump();
    expect(raw, ['{"a":1}', 'not json']);
    expect(json, [
      {'a': 1}
    ]);
    await client.close();
  });

  test('reconnects after an unexpected close with a fresh token', () async {
    final client = build();
    final states = <SocketConnectionState>[];
    client.states.listen(states.add);
    unawaited(client.connect());
    await pump();
    channels.first.open();
    await pump();

    token = 'token-2';
    channels.first.serverClose(1006);
    await pump();
    expect(channels.length, 2);
    expect(handshakes.last['Authorization'], 'Bearer token-2');
    channels.last.open();
    await pump();

    expect(client.state, SocketConnectionState.open);
    expect(states, [
      SocketConnectionState.connecting,
      SocketConnectionState.open,
      SocketConnectionState.reconnecting,
      SocketConnectionState.open,
    ]);
    await client.close();
  });

  test('normal closes (1000, 1001) do not reconnect', () async {
    for (final code in [1000, 1001]) {
      final client = build();
      unawaited(client.connect());
      await pump();
      final before = channels.length;
      channels.last.open();
      await pump();
      channels.last.serverClose(code);
      await pump();
      expect(channels.length, before, reason: 'code $code');
      expect(client.state, SocketConnectionState.closed);
    }
  });

  test('a deliberate close never reconnects', () async {
    final client = build();
    unawaited(client.connect());
    await pump();
    channels.single.open();
    await pump();
    await client.close();
    await pump();
    expect(channels.length, 1);
    expect(client.state, SocketConnectionState.closed);
  });

  test('retries when the connection attempt fails', () async {
    final client = build();
    unawaited(client.connect());
    await pump();
    channels.first.failToOpen();
    await pump();
    expect(channels.length, 2);
    expect(client.state, SocketConnectionState.reconnecting);
    await client.close();
  });

  test('stops reconnecting when shouldReconnect is false (logged out)',
      () async {
    var loggedIn = true;
    final client = build(shouldReconnect: () => loggedIn);
    unawaited(client.connect());
    await pump();
    channels.single.open();
    await pump();
    loggedIn = false;
    channels.single.serverClose(1006);
    await pump();
    expect(channels.length, 1);
    expect(client.state, SocketConnectionState.closed);
  });

  test('registry closeAll closes every socket', () async {
    final a = build();
    final b = build();
    BMWebSocketRegistry.register('prices', a);
    BMWebSocketRegistry.register('beneficiary', b);
    unawaited(a.connect());
    unawaited(b.connect());
    await pump();
    for (final c in channels) {
      c.open();
    }
    await pump();
    await BMWebSocketRegistry.closeAll();
    await pump();
    expect(a.state, SocketConnectionState.closed);
    expect(b.state, SocketConnectionState.closed);
    expect(channels.length, 2);
    expect(BMWebSocketRegistry.get('prices'), isNull);
  });

  test('exponential policy grows, caps and stays within jitter', () {
    const policy = ReconnectPolicy.exponential(
      initial: Duration(seconds: 1),
      max: Duration(seconds: 8),
      jitter: 0.25,
    );
    for (var attempt = 1; attempt <= 6; attempt++) {
      final base = (1000 * (1 << (attempt - 1))).clamp(0, 8000);
      final ms = policy.delayFor(attempt).inMilliseconds;
      expect(ms, inInclusiveRange(base * 0.75, base * 1.25));
    }
  });
}
