/// Error Handling Registry and Mapper for BMFlutter Networking Layer
library;

import 'package:flutter/foundation.dart';

/// Abstract interface that the host app implements to provide error-response decoding logic.
abstract class APIErrorResponseMapper {
  dynamic decode(dynamic json);
}

/// Global registry for [APIErrorResponseMapper].
class APIErrorResponseRegistry {
  APIErrorResponseRegistry._();

  @visibleForTesting
  static APIErrorResponseRegistry createForTesting() =>
      APIErrorResponseRegistry._();

  static APIErrorResponseMapper? _mapper;

  static void register(APIErrorResponseMapper mapper) {
    _mapper = mapper;
  }

  static void clear() {
    _mapper = null;
  }

  static dynamic decode(dynamic json) {
    return _mapper?.decode(json);
  }
}
