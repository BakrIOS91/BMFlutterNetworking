import 'package:http/http.dart' as http;

/// Browsers manage connection timeouts themselves.
http.Client createHttpClient({Duration? connectTimeout}) => http.Client();
