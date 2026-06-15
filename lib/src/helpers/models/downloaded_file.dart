/// Downloaded File Model for BMFlutter Networking Layer
library;

import 'package:http/http.dart' as http;

/// Model representing a file downloaded to the device's temporary directory.
///
/// After `performDownload()` completes, the response stream has already been
/// fully consumed to write the file to disk. [response] still provides useful
/// metadata (headers, statusCode), but [response.stream] is exhausted and
/// should not be read again.
class DownloadedFile {
  /// Local URI of the saved file in the system's temp directory.
  final Uri? downloadedUrl;

  /// The original HTTP streamed response. Headers and statusCode are valid,
  /// but the body stream has already been consumed by the download.
  final http.StreamedResponse? response;

  /// The remote URL the file was downloaded from.
  final Uri? remoteUrl;

  const DownloadedFile({this.downloadedUrl, this.response, this.remoteUrl});

  Map<String, dynamic> toJson() => {
    'downloadedUrl': downloadedUrl?.toString(),
    'remoteUrl': remoteUrl?.toString(),
  };
}
