import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class StepIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const StepIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: context.scaleValue(4)),
          width: isActive ? context.scaleValue(24) : context.scaleValue(8),
          height: context.scaleValue(8),
          decoration: BoxDecoration(
            color: isActive ? context.colors.primary300 : Colors.white38,
            borderRadius: BorderRadius.circular(context.scaleValue(4)),
          ),
        );
      }),
    );
  }
}
