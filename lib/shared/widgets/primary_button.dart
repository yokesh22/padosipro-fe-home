import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Full-width CTA. Stays tappable when [enabled] is false so screens can
/// react (e.g. reveal validation errors); only [isLoading] blocks taps.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: Material(
        color: enabled ? AppColors.primary : AppColors.primaryDisabled,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: Text(
              isLoading ? (loadingLabel ?? label) : label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
