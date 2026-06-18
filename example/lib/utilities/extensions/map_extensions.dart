extension NullableMapCleaner on Map<String, Object?> {
  Map<String, Object> removeNulls() {
    final result = <String, Object>{};
    forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }
}
