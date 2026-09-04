import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The Address -> Delivery -> Payment progress strip at the top of each
/// checkout step.
class CheckoutStepIndicator extends StatelessWidget {
  final int step; // 0, 1, 2
  const CheckoutStepIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
              decoration: BoxDecoration(
                color: i <= step ? AppColors.brand : AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
