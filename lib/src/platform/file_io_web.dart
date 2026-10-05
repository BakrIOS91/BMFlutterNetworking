import 'dart:typed_data';

Future<Uint8List?> readFileBytesFromPath(String path) async {
  throw UnsupportedError('Reading files from a path is not supported on web.');
}

Future<Uri?> saveStreamToTemp(String fileName, Stream<List<int>> stream) async {
  throw UnsupportedError(
    'Saving files to disk is not supported on web. '
    'Collect stream bytes in memory instead.',
  );
}
