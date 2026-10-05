import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/features/auth/account-info/bloc/account_info_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:bm_flutter/core.dart';

class AccountInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountInfoAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountInfoBloc, AccountInfoState>(
      builder: (context, state) {
        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            context.localization.account_info_view_title,
            style: TextStyle(
              fontSize: context.scaleValue(18),
              fontWeight: FontWeight.w600,
              color: context.colors.gray900,
            ),
          ),
          actions: [
            if (state.viewState != ViewState.loading)
              Padding(
                padding: EdgeInsetsDirectional.only(end: context.scaleValue(5)),
                child: _editOrCancelAction(context, state),
              ),
          ],
        );
      },
    );
  }

  Widget _editOrCancelAction(
    BuildContext context,
    AccountInfoState state,
  ) {
    final commonColor = context.colors.gray900;
    final commonSize = context.scaleValue(24);

    if (state.isEditing) {
      return Semantics(
        label: context.localization.commonCancel,
        button: true,
        child: AppButtonStyles.iconButtonPlatform(
          context: context,
          onPressed: () => context
              .read<AccountInfoBloc>()
              .add(const AccountInfoEvent.didTapCancel()),
          icon: const Icon(Icons.close),
          size: commonSize,
          color: commonColor,
        ),
      );
    }

    return AppButtonStyles.iconButtonPlatform(
      context: context,
      onPressed: () => context
          .read<AccountInfoBloc>()
          .add(const AccountInfoEvent.didTapEdit()),
      icon: Image.asset(
        context.imageConstants.editSquare,
        color: commonColor,
        width: commonSize,
        height: commonSize,
      ),
      size: commonSize,
      color: commonColor,
    );
  }
}
