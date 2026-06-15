/// HTTP Request Creation for BMFlutter Networking Layer
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:bm_flutter_networking/src/platform/file_io.dart';

/// Extension to create HTTP requests from TargetRequest configurations
extension Request on TargetRequest {
  Future<http.BaseRequest> createRequest() async {
    try {
      final url = Uri.parse(baseURL).resolve(requestPath);

      final request = http.Request(requestMethod.value, url);
      request.headers.addAll(mergedHeaders);

      switch (requestType) {
        case RequestType.rest:
          return await _configureRESTRequest(request);
        case RequestType.soap:
          return _configureSOAPRequest(request);
      }
    } catch (e) {
      if (e is APIError) rethrow;
      if (e is UnsupportedError) rethrow;
      throw const APIError(APIErrorType.invalidURL);
    }
  }

  Future<http.BaseRequest> _configureRESTRequest(http.Request request) async {
    switch (requestTask.type) {
      case RequestTaskType.plain:
        return request;

      case RequestTaskType.download:
        return request;

      case RequestTaskType.parameters:
        final params = requestTask.parameters;
        if (params != null) {
          final uri = request.url.replace(
            queryParameters: _normalizeQueryParameters(params),
          );
          final newReq = http.Request(request.method, uri)
            ..headers.addAll(request.headers);
          return newReq;
        }
        return request;

      case RequestTaskType.encodedBody:
        final body = requestTask.body;
        if (body != null) {
          try {
            final requestBody = jsonEncode(body);
            request.body = requestBody;
            request.headers['Content-Length'] =
                utf8.encode(requestBody).length.toString();
            request.headers['Content-Type'] = 'application/json';
          } catch (_) {
            throw const APIError(APIErrorType.dataConversionFailed);
          }
        }
        return request;

      case RequestTaskType.uploadFile:
        final filePath = requestTask.filePath;
        if (filePath != null) {
          final bytes = await readFileBytesFromPath(filePath);
          if (bytes == null) {
            throw const APIError(APIErrorType.invalidURL);
          }
          request.bodyBytes = bytes;
          request.headers['Content-Length'] = bytes.length.toString();
        }
        return request;

      case RequestTaskType.uploadMultipart:
        final fields = requestTask.fields;
        if (fields != null) {
          final multipartRequest = http.MultipartRequest(
            request.method,
            request.url,
          );
          multipartRequest.headers.addAll(request.headers);

          for (final entry in fields.entries) {
            if (entry.value is MultipartFormDataData) {
              final data = entry.value as MultipartFormDataData;
              final multipartFile = http.MultipartFile.fromBytes(
                entry.key,
                data.data,
                filename: data.fileName,
                contentType: MediaType.parse(data.mimeType),
              );
              multipartRequest.files.add(multipartFile);
            } else if (entry.value is MultipartFormDataText) {
              final text = entry.value as MultipartFormDataText;
              multipartRequest.fields[entry.key] = text.value.toString();
            }
          }

          return multipartRequest;
        }
        return request;

      case RequestTaskType.downloadResumable:
        final offset = requestTask.offset;
        if (offset != null) {
          request.headers['Range'] = 'bytes=$offset-';
        }
        return request;

      case RequestTaskType.parametersAndBody:
        var newReq = request;

        final params = requestTask.parameters;
        if (params != null) {
          final uri = request.url.replace(
            queryParameters: _normalizeQueryParameters(params),
          );
          newReq = http.Request(request.method, uri)
            ..headers.addAll(request.headers);
        }

        final body = requestTask.body;
        if (body != null) {
          try {
            final requestBody = jsonEncode(body);
            newReq.body = requestBody;
            newReq.headers['Content-Length'] =
                utf8.encode(requestBody).length.toString();
            newReq.headers['Content-Type'] = 'application/json';
          } catch (_) {
            throw const APIError(APIErrorType.dataConversionFailed);
          }
        }

        return newReq;
    }
  }

  http.BaseRequest _configureSOAPRequest(http.Request request) {
    throw const APIError(APIErrorType.notSupportedSOAPOperation);
  }

  Map<String, dynamic> _normalizeQueryParameters(Map<String, dynamic> params) {
    return params.map((key, value) {
      if (value == null) return MapEntry(key, null);
      if (value is Iterable) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, value.toString());
    });
  }
}
