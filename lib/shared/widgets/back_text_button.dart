import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BackTextButton extends StatelessWidget {
  const BackTextButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.chevron_left, size: 22),
      label: const Text('Back'),
    );
  }
}
