/// WebSocket streams for BMFlutter Networking Layer.
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../network/core/network_monitor.dart';
import '../network/token_refresh_handler.dart';
import 'reconnect_policy.dart';
import 'websocket_connector.dart';

/// Connection lifecycle of a [BMWebSocketClient].
enum SocketConnectionState {
  /// First connection attempt in progress.
  connecting,

  /// Connected; messages are flowing.
  open,

  /// The connection dropped unexpectedly; waiting to retry.
  reconnecting,

  /// Closed on purpose (or never started). The client will not reconnect.
  closed,
}

/// Opens a [WebSocketChannel]. Replaced in tests.
typedef WebSocketConnector = WebSocketChannel Function(
  Uri uri,
  Map<String, String> headers,
);

/// A WebSocket that reconnects, authenticates and exposes its messages and
/// connection state as Dart streams.
///
/// ```dart
/// final prices = BMWebSocketClient(
///   url: Uri.parse('wss://api.example.com/api/v2/ranger/private/'),
///   streams: ['global.currencies_prices', 'global.currencies_data'],
///   accessToken: () async => prefs.authLogin?.accessToken,
///   headers: {if (Platform.isIOS) 'User-Agent': 'MyApp'},
/// );
/// BMWebSocketRegistry.register('prices', prices);
/// prices.messages.listen(...);
/// await prices.connect();
/// ```
///
/// Several [streams] share one connection (`?stream=a&stream=b`). Close codes
/// 1000 and 1001 are normal closes and never reconnect; anything else (or a
/// socket error) reconnects according to [reconnectPolicy] until [close] is
/// called or [shouldReconnect] returns false.
class BMWebSocketClient {
  BMWebSocketClient({
    required Uri url,
    this.streams = const [],
    this.accessToken,
    this.headers = const {},
    this.reconnectPolicy = const ReconnectPolicy.exponential(),
    this.refreshTokenOnReconnect = true,
    this.shouldReconnect,
    this.reconnectOnConnectivityRegained = true,
    WebSocketConnector? connector,
  })  : _url = url,
        _connector = connector ?? connectWebSocket;

  final Uri _url;

  /// Stream names added to the URL as repeated `stream` query parameters.
  final List<String> streams;

  /// Supplies the access token for the `Authorization: Bearer` header. Use the
  /// same source as the REST `TokenRefreshHandler` (e.g. secure storage).
  final Future<String?> Function()? accessToken;

  /// Extra handshake headers (for example `User-Agent` on iOS).
  final Map<String, String> headers;

  final ReconnectPolicy reconnectPolicy;

  /// Refresh the token (through [TokenRefreshRegistry]) before every
  /// reconnect, so a socket never comes back with an expired token.
  final bool refreshTokenOnReconnect;

  /// Return false to stop reconnecting, e.g. `() => prefs.isLoggedIn`.
  final bool Function()? shouldReconnect;

  /// Retry immediately when the network comes back instead of waiting out the
  /// backoff delay.
  final bool reconnectOnConnectivityRegained;

  final WebSocketConnector _connector;

  final _messages = StreamController<dynamic>.broadcast();
  final _states = StreamController<SocketConnectionState>.broadcast();
  SocketConnectionState _state = SocketConnectionState.closed;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _retryTimer;
  int _attempt = 0;
  bool _wantOpen = false;
  bool _connecting = false;

  /// Raw messages (usually `String`). See also [jsonMessages].
  Stream<dynamic> get messages => _messages.stream;

  /// Messages decoded from JSON; non-JSON frames are skipped.
  Stream<Object?> get jsonMessages =>
      _messages.stream.where((m) => m is String).map<Object?>((m) {
        try {
          return jsonDecode(m as String);
        } catch (_) {
          return _skip;
        }
      }).where((m) => !identical(m, _skip));
  static final Object _skip = Object();

  /// Connection state changes. Emits only on change.
  Stream<SocketConnectionState> get states => _states.stream;

  SocketConnectionState get state => _state;

  /// The URL that is opened, including the `stream` parameters.
  Uri get uri => streams.isEmpty
      ? _url
      : _url.replace(queryParameters: {
          ..._url.queryParametersAll,
          'stream': streams,
        });

  /// Opens the connection. Does nothing if already connecting or open.
  Future<void> connect() async {
    if (_wantOpen) return;
    _wantOpen = true;
    _attempt = 0;
    _listenConnectivity();
    _setState(SocketConnectionState.connecting);
    await _open();
  }

  /// Sends a text frame (JSON-encodes non-string values).
  void send(Object message) {
    final channel = _channel;
    if (channel == null || _state != SocketConnectionState.open) return;
    channel.sink.add(message is String ? message : jsonEncode(message));
  }

  /// Closes on purpose and stops reconnecting. Use on logout.
  Future<void> close() async {
    _wantOpen = false;
    _retryTimer?.cancel();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _teardownChannel(closeCode: 1000);
    _setState(SocketConnectionState.closed);
  }

  /// Closes and releases the streams. The client cannot be used afterwards.
  Future<void> dispose() async {
    await close();
    await _messages.close();
    await _states.close();
  }

  Future<void> _open() async {
    if (_connecting || !_wantOpen) return;
    _connecting = true;
    try {
      if (_attempt > 0 && refreshTokenOnReconnect) {
        try {
          await TokenRefreshRegistry.refreshToken();
        } catch (_) {
          // No handler registered or refresh failed: use the stored token.
        }
      }
      if (!_wantOpen) return;

      final token = await accessToken?.call();
      final handshake = {
        ...headers,
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final channel = _connector(uri, handshake);
      _channel = channel;
      _channelSubscription = channel.stream.listen(
        _onMessage,
        onError: (Object _) => _onClosed(channel),
        onDone: () => _onClosed(channel),
        cancelOnError: true,
      );

      await channel.ready;
      if (!_wantOpen || _channel != channel) return;
      _attempt = 0;
      _setState(SocketConnectionState.open);
    } catch (_) {
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _onMessage(dynamic message) {
    if (!_messages.isClosed) _messages.add(message);
  }

  void _onClosed(WebSocketChannel channel) {
    if (_channel != channel) return;
    final code = channel.closeCode;
    _channel = null;
    _channelSubscription = null;
    // 1000 normal closure, 1001 going away: the server ended it cleanly.
    if (code == 1000 || code == 1001) {
      if (_wantOpen) {
        _wantOpen = false;
        _setState(SocketConnectionState.closed);
      }
      return;
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_wantOpen) return;
    if (shouldReconnect != null && !shouldReconnect!()) {
      _wantOpen = false;
      _setState(SocketConnectionState.closed);
      return;
    }
    _setState(SocketConnectionState.reconnecting);
    _retryTimer?.cancel();
    _attempt++;
    _retryTimer = Timer(reconnectPolicy.delayFor(_attempt), _open);
  }

  void _listenConnectivity() {
    if (!reconnectOnConnectivityRegained) return;
    _connectivitySubscription ??= NetworkMonitor.onConnectivityChanged.listen(
      (online) {
        if (online &&
            _wantOpen &&
            _state == SocketConnectionState.reconnecting) {
          _retryTimer?.cancel();
          _open();
        }
      },
      onError: (Object _) {},
    );
  }

  Future<void> _teardownChannel({int? closeCode}) async {
    final channel = _channel;
    _channel = null;
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    try {
      await channel?.sink.close(closeCode);
    } catch (_) {}
  }

  void _setState(SocketConnectionState next) {
    if (_state == next) return;
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }
}

/// Keeps named sockets so they can all be closed from anywhere, for example on
/// every logout path.
class BMWebSocketRegistry {
  BMWebSocketRegistry._();

  static final Map<String, BMWebSocketClient> _clients = {};

  /// Registers [client] under [name], closing any previous client with the
  /// same name.
  static void register(String name, BMWebSocketClient client) {
    final previous = _clients[name];
    if (previous != null && !identical(previous, client)) previous.close();
    _clients[name] = client;
  }

  static BMWebSocketClient? get(String name) => _clients[name];

  /// Closes (without reconnecting) and forgets one socket.
  static Future<void> close(String name) async {
    await _clients.remove(name)?.close();
  }

  /// Closes every registered socket. Call on logout.
  static Future<void> closeAll() async {
    final all = _clients.values.toList();
    _clients.clear();
    await Future.wait(all.map((c) => c.close()));
  }
}
