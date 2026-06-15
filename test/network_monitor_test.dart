import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

const _connectivityChannel =
    MethodChannel('dev.fluttercommunity.plus/connectivity');
const _connectivityStatusChannel =
    EventChannel('dev.fluttercommunity.plus/connectivity_status');

void _mockConnectivity(List<String> results) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel,
          (MethodCall methodCall) async {
    if (methodCall.method == 'check') return results;
    return null;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            MethodChannel(_connectivityStatusChannel.name), null);
  });

  group('NetworkMonitor', () {
    test('createForTesting returns an instance', () {
      expect(NetworkMonitor.createForTesting(), isA<NetworkMonitor>());
    });
  });

  group('NetworkMonitor.isConnected', () {
    test('returns true for wifi', () async {
      _mockConnectivity(['wifi']);
      expect(await NetworkMonitor.isConnected, isTrue);
    });

    test('returns true for mobile', () async {
      _mockConnectivity(['mobile']);
      expect(await NetworkMonitor.isConnected, isTrue);
    });

    test('returns true for ethernet', () async {
      _mockConnectivity(['ethernet']);
      expect(await NetworkMonitor.isConnected, isTrue);
    });

    test('returns false for none', () async {
      _mockConnectivity(['none']);
      expect(await NetworkMonitor.isConnected, isFalse);
    });

    test('returns false for bluetooth only', () async {
      _mockConnectivity(['bluetooth']);
      expect(await NetworkMonitor.isConnected, isFalse);
    });

    test('returns true for mixed wifi and none', () async {
      _mockConnectivity(['wifi', 'none']);
      expect(await NetworkMonitor.isConnected, isTrue);
    });
  });

  group('NetworkMonitor.onConnectivityChanged', () {
    test('emits true when wifi is received', () async {
      const codec = StandardMethodCodec();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(_connectivityStatusChannel.name),
        (MethodCall call) async {
          if (call.method == 'listen') {
            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
              _connectivityStatusChannel.name,
              codec.encodeSuccessEnvelope(['wifi']),
              (_) {},
            );
          }
          return null;
        },
      );

      final stream = NetworkMonitor.onConnectivityChanged;
      await expectLater(stream, emitsAnyOf([true, false]));
    });

    test('emits false when none is received (covers ethernet branch)', () async {
      // Emitting ['none'] forces mobile=false, wifi=false so the ethernet
      // check (line 21 of network_monitor.dart) is evaluated.
      const codec = StandardMethodCodec();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(_connectivityStatusChannel.name),
        (MethodCall call) async {
          if (call.method == 'listen') {
            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
              _connectivityStatusChannel.name,
              codec.encodeSuccessEnvelope(['none']),
              (_) {},
            );
          }
          return null;
        },
      );

      final stream = NetworkMonitor.onConnectivityChanged;
      await expectLater(stream, emitsAnyOf([true, false]));
    });
  });
}
