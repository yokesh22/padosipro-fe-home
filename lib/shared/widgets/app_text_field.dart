import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Labelled input matching the design: label above, white rounded field,
/// optional leading icon / prefix text and an error line below.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.prefixText,
    this.errorText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.maxLines = 1,
    this.height = AppSizes.fieldHeightSm,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final String? prefixText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final double height;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final isMultiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            autofillHints: autofillHints,
            maxLines: maxLines,
            expands: false,
            textAlignVertical: isMultiline
                ? TextAlignVertical.top
                : TextAlignVertical.center,
            style: const TextStyle(fontSize: 16, color: AppColors.ink),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMultiline ? 14 : 14,
              ),
              prefixIcon: icon == null && prefixText == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null)
                            Icon(icon, size: 18, color: AppColors.muted),
                          if (icon != null && prefixText != null)
                            const SizedBox(width: 12),
                          if (prefixText != null)
                            Text(
                              prefixText!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                        ],
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(),
              enabledBorder: hasError
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      borderSide: const BorderSide(color: AppColors.error),
                    )
                  : null,
              focusedBorder: hasError
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
