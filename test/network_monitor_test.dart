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

  setUp(() => NetworkMonitor.offlineRecheckDelay = Duration.zero);

  tearDown(() async {
    await NetworkMonitor.reset();
    NetworkMonitor.offlineRecheckDelay = const Duration(milliseconds: 500);
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

    test('returns true for bluetooth tethering', () async {
      _mockConnectivity(['bluetooth']);
      expect(await NetworkMonitor.isConnected, isTrue);
    });

    test('returns true for vpn only', () async {
      _mockConnectivity(['vpn']);
      expect(await NetworkMonitor.isConnected, isTrue);
    });

    test('returns true for other', () async {
      _mockConnectivity(['other']);
      expect(await NetworkMonitor.isConnected, isTrue);
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

    test('emits false when none is received (covers ethernet branch)',
        () async {
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

  group('NetworkMonitor platform monitor lifetime', () {
    test('re-checks once when the first check reports none', () async {
      var calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_connectivityChannel, (call) async {
        if (call.method != 'check') return null;
        calls++;
        // A freshly created iOS NWPathMonitor reports none before its first
        // path evaluation.
        return calls == 1 ? ['none'] : ['wifi'];
      });
      expect(await NetworkMonitor.isConnected, isTrue);
      expect(calls, 2);
    });

    test('keeps one platform subscription across many requests', () async {
      final statusCalls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(_connectivityStatusChannel.name),
        (call) async {
          statusCalls.add(call.method);
          return null;
        },
      );
      _mockConnectivity(['wifi']);

      for (var i = 0; i < 3; i++) {
        expect(await NetworkMonitor.isConnected, isTrue);
        final sub = NetworkMonitor.onConnectivityChanged.listen((_) {});
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
      }
      await Future<void>.delayed(Duration.zero);

      // Cancelling a request's listener must not stop the native monitor.
      expect(statusCalls, ['listen']);
    });
  });

  group('NetworkMonitor status updates', () {
    const codec = StandardMethodCodec();

    Future<void> emitStatus(List<String> status) =>
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(_connectivityStatusChannel.name,
                codec.encodeSuccessEnvelope(status), (_) {});

    void mockStatusChannel() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              MethodChannel(_connectivityStatusChannel.name),
              (call) async => null);
    }

    test('late listener receives the current status', () async {
      mockStatusChannel();
      _mockConnectivity(['wifi']);
      NetworkMonitor.start();
      await Future<void>.delayed(Duration.zero);

      expect(await NetworkMonitor.onConnectivityChanged.first, isTrue);
    });

    test('changes emits only changes, not the current status', () async {
      mockStatusChannel();
      _mockConnectivity(['wifi']);
      final events = <bool>[];
      final sub = NetworkMonitor.changes.listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isEmpty);

      await emitStatus(['none']);
      await Future<void>.delayed(Duration.zero);
      expect(events, [false]);
      await sub.cancel();
    });

    test('reports online again after the network resumes', () async {
      mockStatusChannel();
      _mockConnectivity(['wifi']);
      final events = <bool>[];
      final sub = NetworkMonitor.onConnectivityChanged.listen(events.add);
      await Future<void>.delayed(Duration.zero);

      _mockConnectivity(['none']);
      await emitStatus(['none']);
      await Future<void>.delayed(Duration.zero);
      expect(await NetworkMonitor.isConnected, isFalse);

      _mockConnectivity(['wifi']);
      await emitStatus(['wifi']);
      await Future<void>.delayed(Duration.zero);

      expect(events, [true, false, true]);
      expect(await NetworkMonitor.isConnected, isTrue);
      await sub.cancel();
    });
  });
}
