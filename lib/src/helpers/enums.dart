/// Enums and Constants for BMFlutter Networking Layer
///
/// This file contains all the enumerations, constants, and error types used
/// throughout the BMFlutter networking layer. It provides type-safe definitions
/// for HTTP methods, status codes, request types, error categories, and
/// multipart form data handling.
///
/// Usage:
/// ```dart
/// final method = HTTPMethod.post;
/// final status = HTTPStatusCode.from(200);
/// ```
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Represents different app environments for configuration management
enum AppEnvironment {
  development,
  testing,
  staging,
  preProduction,
  production,
}

extension AppEnvironmentEnv on AppEnvironment {
  static AppEnvironment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;

      case 'testing':
      case 'test':
        return AppEnvironment.testing;

      case 'staging':
        return AppEnvironment.staging;

      case 'preproduction':
      case 'pre_production':
      case 'pre-production':
      case 'preprod':
        return AppEnvironment.preProduction;

      case 'production':
      case 'prod':
        return AppEnvironment.production;

      default:
        return AppEnvironment.development;
    }
  }
}

/// Represents the type of network request protocol
enum RequestType {
  rest,
  soap,
}

/// Represents HTTP request methods as defined in RFC 7231
enum HTTPMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options,
  trace,
  connect,
}

extension HTTPMethodExtension on HTTPMethod {
  String get value => name.toUpperCase();
}

/// Base class for multipart form data types
sealed class MultipartFormData {
  const MultipartFormData();
}

/// Multipart form data for binary file uploads
class MultipartFormDataData extends MultipartFormData {
  final Uint8List data;
  final String fileName;
  final String mimeType;

  const MultipartFormDataData({
    required this.data,
    required this.fileName,
    required this.mimeType,
  });
}

/// Multipart form data for text field uploads
class MultipartFormDataText extends MultipartFormData {
  final dynamic value;

  const MultipartFormDataText(this.value);
}

/// Represents different types of network request tasks
enum RequestTaskType {
  plain,
  parameters,
  encodedBody,
  uploadFile,
  uploadMultipart,
  download,
  downloadResumable,
  parametersAndBody,
}

/// Represents HTTP status code categories for response handling
enum HTTPStatusCode {
  information,
  success,
  redirection,
  notFound,
  notAuthorize,
  clientError,
  serverError,
  unknown;

  static HTTPStatusCode from(int code) {
    if (code >= 100 && code < 200) return HTTPStatusCode.information;
    if (code >= 200 && code < 300) return HTTPStatusCode.success;
    if (code >= 300 && code < 400) return HTTPStatusCode.redirection;
    if (code == 401) return HTTPStatusCode.notAuthorize;
    if (code == 404) return HTTPStatusCode.notFound;
    if (code >= 400 && code < 500) return HTTPStatusCode.clientError;
    if (code >= 500 && code < 600) return HTTPStatusCode.serverError;
    return HTTPStatusCode.unknown;
  }
}

/// Enum for supported locales with their string representations.
enum SupportedLocale {
  // Arabic
  ar("ar"),
  arAE("ar_AE"),
  arBH("ar_BH"),
  arDZ("ar_DZ"),
  arEG("ar_EG"),
  arIQ("ar_IQ"),
  arJO("ar_JO"),
  arKW("ar_KW"),
  arLB("ar_LB"),
  arLY("ar_LY"),
  arMA("ar_MA"),
  arOM("ar_OM"),
  arQA("ar_QA"),
  arSA("ar_SA"),
  arSD("ar_SD"),
  arSY("ar_SY"),
  arTN("ar_TN"),
  arYE("ar_YE"),

  // English
  en("en"),
  enAu("en_AU"),
  enCa("en_CA"),
  enGb("en_GB"),
  enUs("en_US"),

  // German
  de("de"),
  deDe("de_DE"),
  deAt("de_AT"),
  deCh("de_CH"),

  // Spanish
  es("es"),
  esEs("es_ES"),
  esMx("es_MX"),

  // French
  fr("fr"),
  frCa("fr_CA"),
  frFr("fr_FR"),

  // Other languages
  caEs("ca_ES"),
  csCz("cs_CZ"),
  daDk("da_DK"),
  elGr("el_GR"),
  fiFi("fi_FI"),
  hiIn("hi_IN"),
  hrHr("hr_HR"),
  huHu("hu_HU"),
  idId("id_ID"),
  itIt("it_IT"),
  jaJp("ja_JP"),
  koKr("ko_KR"),
  msMy("ms_MY"),
  nbNo("nb_NO"),
  nlNl("nl_NL"),
  plPl("pl_PL"),
  ptBr("pt_BR"),
  ptPt("pt_PT"),
  roRo("ro_RO"),
  ruRu("ru_RU"),
  skSk("sk_SK"),
  svSe("sv_SE"),
  thTh("th_TH"),
  trTr("tr_TR"),
  ukUa("uk_UA"),
  viVn("vi_VN"),
  zhCn("zh_CN"),
  zhHk("zh_HK"),
  zhTw("zh_TW");

  const SupportedLocale(this.rawValue);
  final String rawValue;

  Locale get locale {
    final parts = rawValue.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
}
