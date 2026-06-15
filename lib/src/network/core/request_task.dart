/// Request Task Configuration for BMFlutter Networking Layer
library;

import 'dart:typed_data';

import 'package:bm_flutter_networking/src/helpers/enums.dart';

/// Encapsulates different types of network request tasks with associated data
class RequestTask {
  final RequestTaskType type;
  final Map<String, dynamic>? parameters;
  final dynamic body;
  final String? filePath;
  final Map<String, MultipartFormData>? fields;
  final String? url;
  final Uint8List? resumeData;
  final int? offset;

  const RequestTask._({
    required this.type,
    this.parameters,
    this.body,
    this.filePath,
    this.fields,
    this.url,
    this.resumeData,
    this.offset,
  });

  factory RequestTask.plain() => const RequestTask._(type: RequestTaskType.plain);

  factory RequestTask.parameters(Map<String, dynamic> params) =>
      RequestTask._(type: RequestTaskType.parameters, parameters: params);

  factory RequestTask.encodedBody(dynamic body) =>
      RequestTask._(type: RequestTaskType.encodedBody, body: body);

  factory RequestTask.uploadFile(String filePath) =>
      RequestTask._(type: RequestTaskType.uploadFile, filePath: filePath);

  factory RequestTask.uploadMultipart(Map<String, MultipartFormData> fields) =>
      RequestTask._(type: RequestTaskType.uploadMultipart, fields: fields);

  factory RequestTask.download(String url) =>
      RequestTask._(type: RequestTaskType.download, url: url);

  factory RequestTask.downloadResumable({Uint8List? resumeData, int? offset}) =>
      RequestTask._(
        type: RequestTaskType.downloadResumable,
        resumeData: resumeData,
        offset: offset,
      );

  factory RequestTask.parametersAndBody(Map<String, dynamic> params, dynamic body) =>
      RequestTask._(
        type: RequestTaskType.parametersAndBody,
        parameters: params,
        body: body,
      );
}
