import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

class _TestMapper extends APIErrorResponseMapper {
  @override
  dynamic decode(dynamic json) {
    if (json is Map && json.containsKey('error')) {
      return 'Decoded: ${json['error']}';
    }
    return null;
  }
}

void main() {
  tearDown(() {
    APIErrorResponseRegistry.clear();
  });

  group('APIErrorResponseRegistry', () {
    test('createForTesting returns an instance', () {
      expect(APIErrorResponseRegistry.createForTesting(),
          isA<APIErrorResponseRegistry>());
    });

    test('decode returns null when no mapper registered', () {
      expect(APIErrorResponseRegistry.decode({'error': 'test'}), isNull);
    });

    test('decode calls mapper after registration', () {
      APIErrorResponseRegistry.register(_TestMapper());
      final result = APIErrorResponseRegistry.decode({'error': 'not found'});
      expect(result, 'Decoded: not found');
    });

    test('clear removes registered mapper', () {
      APIErrorResponseRegistry.register(_TestMapper());
      APIErrorResponseRegistry.clear();
      expect(APIErrorResponseRegistry.decode({'error': 'test'}), isNull);
    });

    test('decode with null json returns null', () {
      APIErrorResponseRegistry.register(_TestMapper());
      expect(APIErrorResponseRegistry.decode(null), isNull);
    });

    test('registering a second mapper replaces the first', () {
      final first = _TestMapper();
      final second = _AlwaysNullMapper();
      APIErrorResponseRegistry.register(first);
      APIErrorResponseRegistry.register(second);
      // second mapper always returns null
      expect(APIErrorResponseRegistry.decode({'error': 'test'}), isNull);
    });
  });
}

class _AlwaysNullMapper extends APIErrorResponseMapper {
  @override
  dynamic decode(dynamic json) => null;
}
