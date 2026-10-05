import "package:flutter_example/core/storage_services/hive_box_name.dart";
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_example/core/storage_services/hive_storage_client.dart';

// ---------------------------------------------------------------------------
// Minimal test model — keeps tests self-contained and framework-agnostic.
// ---------------------------------------------------------------------------
class _Item {
  const _Item({required this.id, required this.name});

  final int id;
  final String name;

  factory _Item.fromJson(Map<String, dynamic> json) =>
      _Item(id: json['id'] as int, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is _Item && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
const _box = HiveBoxName.hotelBookings;

final _itemA = const _Item(id: 1, name: 'Alpha');
final _itemB = const _Item(id: 2, name: 'Beta');
final _itemC = const _Item(id: 3, name: 'Gamma');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late Directory tempDir;
  late HiveStorageClient client;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_client_test_');
    Hive.init(tempDir.path);
    client = HiveStorageClient();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_box.value);
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('HiveStorageClient', () {
    // ── add / fetchAll ─────────────────────────────────────────────────────

    test('fetchAll returns empty list when box is empty', () async {
      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
      );
      expect(result, isEmpty);
    });

    test('add then fetchAll returns the saved item', () async {
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
      );

      expect(result, hasLength(1));
      expect(result.first, equals(_itemA));
    });

    test('multiple adds are persisted and all retrieved', () async {
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemB, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemC, toJson: (i) => i.toJson());

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
      );

      expect(result, hasLength(3));
    });

    // ── reverseOrder ───────────────────────────────────────────────────────

    test('fetchAll with reverseOrder=true (default) returns newest first',
        () async {
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemB, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemC, toJson: (i) => i.toJson());

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
        // reverseOrder defaults to true
      );

      expect(result, [_itemC, _itemB, _itemA]);
    });

    test('fetchAll with reverseOrder=false returns insertion order', () async {
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemB, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemC, toJson: (i) => i.toJson());

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
        reverseOrder: false,
      );

      expect(result, [_itemA, _itemB, _itemC]);
    });

    // ── delete ─────────────────────────────────────────────────────────────

    test('delete removes only the entry with the given key', () async {
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemB, toJson: (i) => i.toJson());

      // Hive auto-increments keys starting at 0
      await client.delete(box: _box, key: 0);

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
        reverseOrder: false,
      );

      expect(result, hasLength(1));
      expect(result.first, equals(_itemB));
    });

    // ── clear ──────────────────────────────────────────────────────────────

    test('clear removes all entries from the box', () async {
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemB, toJson: (i) => i.toJson());
      await client.add(box: _box, item: _itemC, toJson: (i) => i.toJson());

      await client.clear(box: _box);

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
      );

      expect(result, isEmpty);
    });

    // ── resilience ─────────────────────────────────────────────────────────

    test('fetchAll silently skips corrupted / non-parseable entries', () async {
      // Manually inject a bad JSON string directly into the box
      final rawBox = await Hive.openBox<String>(_box.value);
      await rawBox.add('NOT VALID JSON {{{{');
      await client.add(box: _box, item: _itemA, toJson: (i) => i.toJson());

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
        reverseOrder: false,
      );

      // Only the valid item should be returned
      expect(result, hasLength(1));
      expect(result.first, equals(_itemA));
    });

    test('fetchAll skips entries whose fromJson throws', () async {
      // Valid JSON but missing required fields — _Item.fromJson will throw
      final rawBox = await Hive.openBox<String>(_box.value);
      await rawBox.add('{"wrong_field": 99}');
      await client.add(box: _box, item: _itemB, toJson: (i) => i.toJson());

      final result = await client.fetchAll<_Item>(
        box: _box,
        fromJson: _Item.fromJson,
        reverseOrder: false,
      );

      expect(result, hasLength(1));
      expect(result.first, equals(_itemB));
    });
  });
}
