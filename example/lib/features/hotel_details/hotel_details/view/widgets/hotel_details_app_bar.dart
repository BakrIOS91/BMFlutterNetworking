import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

class AppBarHeader extends StatelessWidget {
  final String imageUrl;

  const AppBarHeader({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.scaleValue(350),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            imageUrl: imageUrl,
            placeholder: context.imageConstants.appLogo,
            fit: BoxFit.cover,
          ),

          /// overlay for readability
          Container(
            color: context.colors.gray950.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class HotelDetailsTopAppBar extends StatelessWidget {
  final bool isCollapsed;

  const HotelDetailsTopAppBar({
    super.key,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const double iconWidth = kToolbarHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: kToolbarHeight + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: isCollapsed ? context.colors.gray0 : Colors.transparent,
        boxShadow: isCollapsed
            ? [
                BoxShadow(
                  color: context.colors.gray950.withValues(alpha: 0.08),
                  blurRadius: context.scaleValue(10),
                  offset: Offset(0, context.scaleValue(4)),
                ),
              ]
            : [], // No shadow when transparent/expanded
      ),
      child: Row(
        children: [
          /// Back button
          SizedBox(
            width: iconWidth,
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                size: context.scaleValue(32),
                color:
                    isCollapsed ? context.colors.gray950 : context.colors.white,
              ),
              onPressed: () => context.router.maybePop(),
            ),
          ),

          /// Centered title
          Expanded(
            child: Text(
              context.localization.common_details,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    isCollapsed ? context.colors.gray950 : context.colors.white,
                fontWeight: FontWeight.bold,
                fontSize: context.scaleValue(18),
              ),
            ),
          ),

          /// Empty space to balance the back button
          SizedBox(width: iconWidth),
        ],
      ),
    );
  }
}
