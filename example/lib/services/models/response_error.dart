import 'package:bm_flutter_networking/bm_flutter_networking.dart';

class ResponseError {
  int? code;
  String? errorCode;
  String? msg;

  ResponseError({
    this.code,
    this.errorCode,
    this.msg,
  });

  factory ResponseError.fromJson(Map<String, dynamic> json) => ResponseError(
        code: json["code"],
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "error_code": errorCode,
        "msg": msg,
      };
}

class ResponseErrorMapper implements APIErrorResponseMapper {
  @override
  dynamic decode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ResponseError.fromJson(json);
    }
    return null;
  }
}
