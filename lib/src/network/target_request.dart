/// Target Request Protocol for BMFlutter Networking Layer
library;

import 'package:bm_flutter_networking/src/helpers/enums.dart';

import 'core/network_monitor.dart';
import 'core/request_task.dart';
import 'core/ssl_pinning.dart';

/// Defines the required properties for a target network request
abstract class TargetRequest {
  RequestType get requestType;
  String get baseURL;
  String get requestPath;
  HTTPMethod get requestMethod;
  RequestTask get requestTask;
  bool get isAuthorized;
  Map<String, String> get headers;
  Map<String, String> get authHeaders;
  SSLPinningConfiguration? get sslPinningConfiguration;
  bool get useUniqueFilename => false;

  Map<String, String> get mergedHeaders {
    final combined = {...headers, ...authHeaders};
    return {...defaultHeaders, ...combined};
  }

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

  static Future<bool> get isConnectedToInternet async {
    return await NetworkMonitor.isConnected;
  }

  String get requestTaskDescription {
    switch (requestTask.type) {
      case RequestTaskType.plain:
        return 'Plain request';
      case RequestTaskType.parameters:
        return 'Parameters: ${requestTask.parameters}';
      case RequestTaskType.encodedBody:
        return 'Body: ${requestTask.body}';
      case RequestTaskType.uploadFile:
        return 'Upload file: ${requestTask.filePath}';
      case RequestTaskType.uploadMultipart:
        return 'Multipart fields: ${requestTask.fields?.keys.toList()}';
      case RequestTaskType.download:
        return 'Download from: ${requestTask.url}';
      case RequestTaskType.downloadResumable:
        return 'Resumable download with offset: ${requestTask.offset}';
      case RequestTaskType.parametersAndBody:
        return 'Parameters: ${requestTask.parameters}, Body: ${requestTask.body}';
    }
  }
}

/// Marker interface for simple "success-only" requests (no data decoding)
abstract class SuccessTargetType extends TargetRequest {
  @override
  RequestType get requestType => RequestType.rest;

  @override
  bool get isAuthorized => false;

  @override
  Map<String, String> get headers => {};

  @override
  Map<String, String> get authHeaders => {};

  @override
  RequestTask get requestTask => RequestTask.plain();

  @override
  SSLPinningConfiguration? get sslPinningConfiguration => null;
}

/// Model-based request for decoding data into a model [T]
abstract class ModelTargetType<T> extends TargetRequest {
  final T Function(Map<String, dynamic>)? decoder;

  ModelTargetType({this.decoder});

  @override
  RequestType get requestType => RequestType.rest;

  @override
  bool get isAuthorized => false;

  @override
  Map<String, String> get headers => {};

  @override
  Map<String, String> get authHeaders => {};

  @override
  RequestTask get requestTask => RequestTask.plain();

  @override
  SSLPinningConfiguration? get sslPinningConfiguration => null;

  T fromJson(Map<String, dynamic> json) {
    if (decoder != null) {
      return decoder!(json);
    }
    throw UnimplementedError(
      'fromJson MUST be overridden or a decoder MUST be provided in the constructor for ModelTargetType<$T>',
    );
  }
}
