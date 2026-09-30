import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/back_text_button.dart';

/// Layout shared by the request flow screens: back link, optional [header],
/// title, subtitle, scrolling [children] and a sticky [footer].
class RequestFlowPage extends StatelessWidget {
  const RequestFlowPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
    this.header,
  });

  final String title;
  final String subtitle;
  final Widget? header;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: BackTextButton(onPressed: () => context.pop()),
                    ),
                    const SizedBox(height: 18),
                    if (header != null) ...[
                      header!,
                      const SizedBox(height: 16),
                    ],
                    Text(
                      title,
                      style: textTheme.headlineLarge?.copyWith(fontSize: 27),
                    ),
                    const SizedBox(height: 10),
                    Text(subtitle, style: textTheme.bodyMedium),
                    const SizedBox(height: 22),
                    ...children,
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                math.max(34, bottomInset + 16),
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: Color(0x14000000))),
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

class FlowSectionLabel extends StatelessWidget {
  const FlowSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 11.5 * 0.07,
        color: AppColors.muted,
      ),
    );
  }
}

/// Rounded choice pill: white with a grey border, or solid green when
/// [selected].
class FlowPill extends StatelessWidget {
  const FlowPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selectable card background: white with a grey border, or green-tinted
/// with a green border when [selected].
BoxDecoration flowCardDecoration({required bool selected}) => BoxDecoration(
  color: selected ? AppColors.selectedBg : AppColors.surface,
  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
);
