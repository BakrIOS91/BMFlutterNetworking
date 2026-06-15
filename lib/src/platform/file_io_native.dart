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
  await stream.pipe(sink);
  await sink.close();
  return file.uri;
}
