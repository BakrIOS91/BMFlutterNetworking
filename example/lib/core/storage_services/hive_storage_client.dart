import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_example/core/storage_services/hive_box_name.dart';

@lazySingleton
class HiveStorageClient {
  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<Box<String>> _openBox(HiveBoxName boxName) async {
    if (!Hive.isBoxOpen(boxName.value)) {
      await Hive.openBox<String>(boxName.value);
    }
    return Hive.box<String>(boxName.value);
  }

  // ── Create ────────────────────────────────────────────────────────────────

  /// Appends [item] to the box using an auto-increment key.
  Future<void> add<T>({
    required HiveBoxName box,
    required T item,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final hiveBox = await _openBox(box);
    final jsonString = jsonEncode(toJson(item));
    await hiveBox.add(jsonString);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns all items from the box, decoded with [fromJson].
  /// Pass [reverseOrder] = true (default) to get newest-first ordering.
  Future<List<T>> fetchAll<T>({
    required HiveBoxName box,
    required T Function(Map<String, dynamic>) fromJson,
    bool reverseOrder = true,
  }) async {
    final hiveBox = await _openBox(box);
    final List<T> items = [];

    for (final jsonString in hiveBox.values) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        items.add(fromJson(jsonMap));
      } catch (e, st) {
        // Skip corrupted entries, but surface errors during development
        assert(() {
          if (!Platform.environment.containsKey('FLUTTER_TEST')) {
            debugPrint('[HiveStorageClient] Failed to decode entry: $e\n$st');
          }
          return true;
        }());
      }
    }

    return reverseOrder ? items.reversed.toList() : items;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Deletes the entry identified by [key].
  /// [key] must be the auto-increment [int] key assigned by Hive.
  Future<void> delete({
    required HiveBoxName box,
    required int key,
  }) async {
    final hiveBox = await _openBox(box);
    await hiveBox.delete(key);
  }

  /// Deletes the first entry matching [predicate].
  /// Returns `true` if a matching entry was found and deleted.
  Future<bool> deleteWhere<T>({
    required HiveBoxName box,
    required T Function(Map<String, dynamic>) fromJson,
    required bool Function(T) predicate,
  }) async {
    final hiveBox = await _openBox(box);

    for (final key in hiveBox.keys) {
      final stored = hiveBox.get(key);
      if (stored == null) continue;
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(stored);
        final item = fromJson(jsonMap);
        if (predicate(item)) {
          await hiveBox.delete(key);
          return true;
        }
      } catch (e, st) {
        // Skip corrupted entries, but surface errors during development
        assert(() {
          if (!Platform.environment.containsKey('FLUTTER_TEST')) {
            debugPrint('[HiveStorageClient] Failed to decode entry: $e\n$st');
          }
          return true;
        }());
      }
    }
    return false;
  }

  /// Removes all entries from the box.
  Future<void> clear({required HiveBoxName box}) async {
    final hiveBox = await _openBox(box);
    await hiveBox.clear();
  }

  /// Clears all known Hive boxes. Used during logout.
  Future<void> clearAll() async {
    for (final box in HiveBoxName.values) {
      await clear(box: box);
    }
  }
}
