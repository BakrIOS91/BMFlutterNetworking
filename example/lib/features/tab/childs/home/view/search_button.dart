import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/tab/childs/home/bloc/home_bloc.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.scaleValue(44),
      height: context.scaleValue(44),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.border,
          width: context.scaleValue(1),
        ),
      ),
      child: AppButtonStyles.iconButtonPlatform(
        context: context,
        padding: EdgeInsets.zero,
        icon: AppIcon(
            asset: AppIcons.search,
            size: context.scaleValue(24),
            color: context.colors.textGray0),
        onPressed: () async {
          await context.router.push(const SearchRoute());
          if (context.mounted) {
            context.read<HomeBloc>().add(const HomeEvent.refresh());
          }
        },
      ),
    );
  }
}
