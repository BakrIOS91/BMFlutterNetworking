import 'dart:async';

import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProvider implements ConnectivityProvider {
  _FakeProvider(this.online);

  bool online;
  int checks = 0;
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async {
    checks++;
    return online;
  }

  @override
  Stream<bool> get onChanged => controller.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fail loudly if connectivity_plus is touched while a provider is set.
  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  var pluginCalls = 0;

  setUp(() {
    pluginCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      pluginCalls++;
      return <String>['wifi'];
    });
  });

  tearDown(() async {
    NetworkMonitor.useProvider(null);
    await NetworkMonitor.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isConnected asks the provider and never the plugin', () async {
    final provider = _FakeProvider(true);
    NetworkMonitor.useProvider(provider);

    expect(await NetworkMonitor.isConnected, isTrue);
    provider.online = false;
    expect(await NetworkMonitor.isConnected, isFalse);

    expect(provider.checks, 2);
    expect(pluginCalls, 0);
  });

  test('changes forwards provider events', () async {
    final provider = _FakeProvider(true);
    NetworkMonitor.useProvider(provider);

    final events = <bool>[];
    final sub = NetworkMonitor.changes.listen(events.add);
    provider.controller.add(false);
    provider.controller.add(true);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events, [false, true]);
    expect(pluginCalls, 0);
  });

  test('onConnectivityChanged seeds the current status then follows changes',
      () async {
    final provider = _FakeProvider(false);
    NetworkMonitor.useProvider(provider);

    final events = <bool>[];
    final sub = NetworkMonitor.onConnectivityChanged.listen(events.add);
    await Future<void>.delayed(Duration.zero);
    provider.controller.add(true);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events, [false, true]);
    expect(pluginCalls, 0);
  });

  test('removing the provider returns to connectivity_plus', () async {
    NetworkMonitor.useProvider(_FakeProvider(false));
    expect(await NetworkMonitor.isConnected, isFalse);

    NetworkMonitor.useProvider(null);
    expect(await NetworkMonitor.isConnected, isTrue);
    expect(pluginCalls, greaterThan(0));
  });
}
