import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class CheckoutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isViewing;
  const CheckoutAppBar({super.key, this.isViewing = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        isViewing
            ? context.localization.checkout_booking_details
            : context.localization.checkout_title,
        style: AppTextStyles.headlineMedium(
          context,
          color: context.colors.gray900,
        ),
      ),
      actions: [
        if (!isViewing)
          Padding(
            padding: EdgeInsetsDirectional.only(end: context.scaleValue(4)),
            child: const _MoreActionsButton(),
          ),
      ],
    );
  }
}

class _MoreActionsButton extends StatelessWidget {
  const _MoreActionsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_vert,
        color: context.colors.gray900,
        size: context.scaleValue(24),
      ),
      tooltip: context.localization.checkout_more_options,
      onPressed: () => _showActionsMenu(context),
    );
  }

  void _showActionsMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<_CheckoutMenuAction>(
      context: context,
      color: context.colors.gray0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scaleValue(12)),
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: [
        PopupMenuItem<_CheckoutMenuAction>(
          value: _CheckoutMenuAction.cancel,
          child: Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                color: context.colors.alertError100,
                size: context.scaleValue(20),
              ),
              SizedBox(width: context.scaleValue(8)),
              Text(
                context.localization.checkout_cancel_booking,
                style: AppTextStyles.bodySmall(
                  context,
                  color: context.colors.alertError100,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((action) {
      if (action == _CheckoutMenuAction.cancel && context.mounted) {
        // Pop all routes until the tab root (My Bookings tab) is reached,
        // regardless of how many screens sit between BookingView and this one.
        context.router.popUntilRoot();
      }
    });
  }
}

enum _CheckoutMenuAction { cancel }
