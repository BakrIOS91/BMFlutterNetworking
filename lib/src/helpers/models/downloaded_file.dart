/// Downloaded File Model for BMFlutter Networking Layer
library;

import 'package:http/http.dart' as http;

/// Model representing a downloaded file with metadata
class DownloadedFile {
  final Uri? downloadedUrl;
  final http.StreamedResponse? response;
  final Uri? remoteUrl;

  const DownloadedFile({this.downloadedUrl, this.response, this.remoteUrl});

  Map<String, dynamic> toJson() => {
    'downloadedUrl': downloadedUrl?.toString(),
    'remoteUrl': remoteUrl?.toString(),
  };
}
