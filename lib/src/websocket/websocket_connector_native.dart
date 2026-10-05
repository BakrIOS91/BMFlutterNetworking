import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a socket sending [headers] in the handshake (Authorization, ...).
WebSocketChannel connectWebSocket(Uri uri, Map<String, String> headers) =>
    IOWebSocketChannel.connect(uri, headers: headers);
