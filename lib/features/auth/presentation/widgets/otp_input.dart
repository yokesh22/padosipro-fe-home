import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';

/// Six OTP boxes driven by one invisible [TextField], so typing, deleting,
/// SMS/email autofill and paste all behave like a normal input.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.enabled = true,
    this.hasError = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final int length;
  final bool enabled;

  /// Outlines every box in the error color.
  final bool hasError;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Color _borderFor(int index, String code) {
    if (widget.hasError) return AppColors.error;
    final active = index == code.length.clamp(0, widget.length - 1);
    if (_focusNode.hasFocus && active) return AppColors.primary;
    if (index < code.length) return AppColors.otpFilled;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;

    return SizedBox(
      height: AppSizes.otpBoxHeight,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? AppColors.surface
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: _borderFor(i, code),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      i < code.length ? code[i] : '',
                      style: const TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Positioned.fill(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: true,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: widget.onChanged,
              showCursor: false,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              // Override every border state so the theme's focused outline
              // isn't drawn over the boxes.
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
