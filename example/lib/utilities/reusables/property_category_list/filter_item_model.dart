import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

/// Represents a filter item for the UI
/// Wraps the enum label and optional icon
class FilterItem {
  final String label;
  final String? iconPath;

  const FilterItem({required this.label, this.iconPath});
}

/// Displays an icon for a filter item
/// Handles null icons gracefully
class FilterItemIcon extends StatelessWidget {
  final String? iconPath;

  const FilterItemIcon({super.key, this.iconPath});

  @override
  Widget build(BuildContext context) {
    if (iconPath == null || iconPath!.isEmpty) {
      return const SizedBox(width: 0, height: 0); // Empty widget if no icon
    }
    return AppImage(
        imageUrl: iconPath,
        width: context.scaleValue(24),
        height: context.scaleValue(24));
  }
}
