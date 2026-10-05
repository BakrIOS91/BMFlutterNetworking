import 'package:bm_flutter/core.dart';

enum AppFontWeight implements FontWeightProtocol {
  regular,
  medium,
  semiBold,
  bold;

  @override
  int get weightValue {
    switch (this) {
      case AppFontWeight.regular:
        return 400;
      case AppFontWeight.medium:
        return 500;
      case AppFontWeight.semiBold:
        return 600;
      case AppFontWeight.bold:
        return 700;
    }
  }
}

enum Status { success, fail, warning, question }

enum EmailErrorType {
  none,
  empty,
  invalidFormat;

  bool get isError => this != EmailErrorType.none;
}

enum AtPage { first, next }
