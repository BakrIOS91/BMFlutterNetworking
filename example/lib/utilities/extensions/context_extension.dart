import 'package:flutter/material.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/utilities/constants/color_constants.dart';
import 'package:flutter_example/utilities/constants/image_constants.dart';
import 'package:flutter_example/utilities/extensions/app_localizations_extension.dart';
import 'package:flutter_example/utilities/l10n/app_localizations.dart';
import 'package:bm_flutter/core.dart';

extension ContextExtension on BuildContext {
  double scaleValue(num value) => value * DeviceHelper.getScalingFactor(this);
  AppLocalizations get localization => AppLocalizationsSafe.of(this);
  ImageConstants get imageConstants => getIt();
  AppColors get colors => AppColors(Theme.of(this).brightness);
}
