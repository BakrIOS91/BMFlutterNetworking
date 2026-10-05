import 'package:web_socket_channel/web_socket_channel.dart';

/// Browsers cannot set handshake headers; [headers] are ignored on web.
WebSocketChannel connectWebSocket(Uri uri, Map<String, String> headers) =>
    WebSocketChannel.connect(uri);
