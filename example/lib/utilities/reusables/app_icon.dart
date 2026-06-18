import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    this.icon,
    this.asset,
    this.size = 24,
    this.color,
    this.matchTextDirection = true,
  });

  final IconData? icon;
  final String? asset;
  final double size;
  final Color? color;
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    // Material icon
    if (icon != null) {
      iconWidget = Icon(icon, size: size, color: color);
    } else if (asset != null && asset!.endsWith('.svg')) {
      // SVG icon
      iconWidget = SvgPicture.asset(
        asset!,
        width: size,
        height: size,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else {
      // PNG icon
      iconWidget = Image.asset(
        asset!,
        width: size,
        height: size,
        color: color,
      );
    }

    if (matchTextDirection) {
      return Transform.flip(
        flipX: Directionality.of(context) == TextDirection.rtl,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
