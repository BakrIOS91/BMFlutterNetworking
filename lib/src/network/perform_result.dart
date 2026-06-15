/// Result-Based Network Operations for BMFlutter Networking Layer
library;

import 'package:bm_flutter_networking/src/helpers/api_error.dart';
import 'package:bm_flutter_networking/src/helpers/enums.dart';
import 'package:bm_flutter_networking/src/helpers/models/downloaded_file.dart';
import 'package:bm_flutter_networking/src/network/perform_async.dart';
import 'package:bm_flutter_networking/src/network/target_request.dart';

import 'core/network_response.dart';
import 'core/result.dart';

extension PerformResultModelTargetType on ModelTargetType {
  Future<Result<Response, APIError>> performResult<Response>() async {
    try {
      final response = await performAsync<Response>();
      return Success<Response, APIError>(response);
    } on APIError catch (error) {
      return Failure<Response, APIError>(error);
    }
  }

  Future<Result<NetworkResponse<Response>, APIError>>
      performResultWithCookies<Response>() async {
    try {
      final response = await performAsyncWithCookies<Response>();
      return Success<NetworkResponse<Response>, APIError>(response);
    } on APIError catch (error) {
      return Failure<NetworkResponse<Response>, APIError>(error);
    }
  }

  Future<Result<DownloadedFile?, APIError>> performDownloadResult() async {
    try {
      final result = await performDownload();
      return Success<DownloadedFile?, APIError>(result);
    } on APIError catch (error) {
      return Failure<DownloadedFile?, APIError>(error);
    }
  }
}

extension PerformResultSuccessTargetType on SuccessTargetType {
  Future<Result<void, APIError>> performResult() async {
    try {
      await performAsync();
      return const Success<void, APIError>(null);
    } on APIError catch (error) {
      return Failure<void, APIError>(error);
    }
  }

  Future<Result<NetworkResponse<void>, APIError>>
      performResultWithCookies() async {
    try {
      final response = await performAsyncWithCookies();
      return Success<NetworkResponse<void>, APIError>(response);
    } on APIError catch (error) {
      return Failure<NetworkResponse<void>, APIError>(error);
    }
  }
}
