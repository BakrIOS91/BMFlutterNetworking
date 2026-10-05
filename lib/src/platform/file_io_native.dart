import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> readFileBytesFromPath(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

Future<Uri?> saveStreamToTemp(String fileName, Stream<List<int>> stream) async {
  final file = File('${Directory.systemTemp.path}/$fileName');
  final sink = file.openWrite();
  try {
    await stream.pipe(sink); // pipe() closes the sink on success
  } catch (e) {
    await sink.close(); // ensure the sink is closed on the error path
    rethrow;
  }
  return file.uri;
}
