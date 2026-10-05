import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Creates the client for one request, applying [connectTimeout].
http.Client createHttpClient({Duration? connectTimeout}) {
  if (connectTimeout == null) return http.Client();
  return IOClient(HttpClient()..connectionTimeout = connectTimeout);
}
