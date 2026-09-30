import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/create_task_notifier.dart';
import '../providers/service_request_draft.dart';
import '../widgets/request_flow_widgets.dart';

/// Request flow step 3: a line or two of detail, then send. Pops with the
/// "request sent" message.
class RequestDetailsScreen extends ConsumerStatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  ConsumerState<RequestDetailsScreen> createState() =>
      _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends ConsumerState<RequestDetailsScreen> {
  // Seeded from the draft so the text survives going back and forward.
  late final _details = TextEditingController(
    text: ref.read(serviceRequestDraftProvider).details,
  );

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final draft = ref.read(serviceRequestDraftProvider);
    if (!draft.canSend) return;
    final created = await ref.read(createTaskProvider.notifier).submit(draft);
    if (created != null && mounted) {
      context.pop('${draft.service} request sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createTaskProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final draft = ref.watch(serviceRequestDraftProvider);
    final isLoading = ref.watch(createTaskProvider).isLoading;
    final category = draft.category;
    final timingLabel = draft.timingLabel;

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(color: color, width: width),
        );

    return RequestFlowPage(
      title: 'Tell us a little more',
      subtitle: "One or two lines is enough. We'll take it from there.",
      header: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (category != null && draft.service != null)
            _Chip(
              label: '${category.label} · ${draft.service}',
              background: AppColors.soonBg,
              border: AppColors.soonBorder,
              foreground: AppColors.partnerInk,
            ),
          if (timingLabel != null)
            _Chip(
              label: timingLabel,
              background: AppColors.mint,
              border: AppColors.mintBorder,
              foreground: AppColors.primary,
            ),
        ],
      ),
      footer: PrimaryButton(
        label: 'Leave it with us',
        loadingLabel: 'Sending…',
        enabled: draft.canSend,
        isLoading: isLoading,
        onPressed: _send,
      ),
      children: [
        SizedBox(
          height: 140,
          child: TextField(
            controller: _details,
            onChanged: ref
                .read(serviceRequestDraftProvider.notifier)
                .setDetails,
            enabled: !isLoading,
            expands: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            // Backend limit.
            maxLength: 1000,
            buildCounter: _noCounter,
            textCapitalization: TextCapitalization.sentences,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              height: 1.45,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: category?.detailsHint,
              hintMaxLines: 3,
              contentPadding: const EdgeInsets.all(16),
              border: outline(AppColors.border),
              enabledBorder: outline(AppColors.border),
              disabledBorder: outline(AppColors.border),
              focusedBorder: outline(AppColors.primary, 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(Icons.info_outline, size: 15, color: AppColors.muted),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Pilot LM will call if anything needs clarifying.',
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color border;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

Widget? _noCounter(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) => null;
