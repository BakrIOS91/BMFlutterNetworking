import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';
import 'package:flutter_example/utilities/constants/image_constants.dart';

class ProfileHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String avatarUrl;
  final double avatarSize;
  final String? subtitleIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarUrl,
    this.avatarSize = 40.0,
    this.subtitleIcon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        _Avatar(avatarUrl: avatarUrl, size: avatarSize),
        SizedBox(width: context.scaleValue(10)),
        Expanded(
          child: _ProfileInfo(
            title: title,
            subtitle: subtitle,
            subtitleIcon: subtitleIcon,
            isLarge: avatarSize > 40.0,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class _Avatar extends StatelessWidget {
  final String avatarUrl;
  final double size;

  const _Avatar({required this.avatarUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final image = avatarUrl.isEmpty || avatarUrl == 'null'
        ? ImageConstants.user
        : avatarUrl;

    return Container(
      width: context.scaleValue(size),
      height: context.scaleValue(size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.gray100,
      ),
      child: AppImage(
        imageUrl: image,
        width: context.scaleValue(size),
        height: context.scaleValue(size),
        radius: BorderRadius.circular(context.scaleValue(size / 2)),
        placeholder: ImageConstants.user,
        errorWidget: AppImage(
          imageUrl: ImageConstants.user,
          width: context.scaleValue(size),
          height: context.scaleValue(size),
          radius: BorderRadius.circular(context.scaleValue(size / 2)),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? subtitleIcon;
  final bool isLarge;

  const _ProfileInfo({
    required this.title,
    required this.subtitle,
    this.subtitleIcon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge(
            context,
            color: isLarge ? context.colors.gray900 : context.colors.textGray0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.trim().isNotEmpty) ...[
          SizedBox(height: context.scaleValue(isLarge ? 4 : 3)),
          _SubtitleRow(subtitle: subtitle, subtitleIcon: subtitleIcon, isLarge: isLarge),
        ],
      ],
    );
  }
}

class _SubtitleRow extends StatelessWidget {
  final String subtitle;
  final String? subtitleIcon;
  final bool isLarge;

  const _SubtitleRow({required this.subtitle, this.subtitleIcon, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final textColor = isLarge ? context.colors.gray400 : context.colors.textGray700;
    return Row(
      children: [
        if (subtitleIcon != null) ...[
          AppIcon(
              asset: subtitleIcon!,
              size: context.scaleValue(16),
              color: textColor),
          SizedBox(width: context.scaleValue(4)),
        ],
        Flexible(
          child: Text(
            subtitle,
            style: AppTextStyles.bodySmall(
              context,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
