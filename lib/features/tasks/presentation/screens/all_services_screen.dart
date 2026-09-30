import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/service_catalog.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/service_request_draft.dart';
import '../widgets/request_flow_widgets.dart';

/// Request flow step 1: pick a category, a kind of help and a service.
/// Pops with the "request sent" message once the flow completes.
class AllServicesScreen extends ConsumerStatefulWidget {
  const AllServicesScreen({super.key, this.initialCategory});

  final int? initialCategory;

  @override
  ConsumerState<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends ConsumerState<AllServicesScreen> {
  static const _categories = ServiceCatalog.categories;

  final _cardKeys = List.generate(_categories.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    if (initial != null) {
      // Providers can't change during initState; this lands while the page
      // is still transitioning in.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(serviceRequestDraftProvider.notifier).selectCategory(initial);
        _scrollTo(initial);
      });
    }
  }

  void _scrollTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _cardKeys[index].currentContext;
      if (ctx == null || !ctx.mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _selectCategory(int index) {
    if (ref.read(serviceRequestDraftProvider).categoryIndex == index) return;
    ref.read(serviceRequestDraftProvider.notifier).selectCategory(index);
    _scrollTo(index);
  }

  Future<void> _continue() async {
    if (ref.read(serviceRequestDraftProvider).service == null) return;
    final sent = await context.push<String>(Routes.requestWhen);
    if (sent != null && mounted) context.pop(sent);
  }

  Future<void> _openPartner(Partner partner) async {
    final opened = await launchUrl(
      Uri.parse(partner.url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Couldn\'t open ${partner.label}.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(serviceRequestDraftProvider);
    final notifier = ref.read(serviceRequestDraftProvider.notifier);

    return RequestFlowPage(
      title: 'What do you need help with?',
      subtitle:
          'Pick a category, then choose a service. You can add details next.',
      footer: PrimaryButton(
        label: 'Continue',
        enabled: draft.service != null,
        onPressed: _continue,
      ),
      children: [
        for (var i = 0; i < _categories.length; i++)
          Padding(
            key: _cardKeys[i],
            padding: const EdgeInsets.only(bottom: 14),
            child: _CategoryCard(
              category: _categories[i],
              draft: draft.categoryIndex == i ? draft : null,
              onTap: () => _selectCategory(i),
              onHelpTypeTap: notifier.selectHelpType,
              onServiceTap: notifier.toggleService,
              onPartnerTap: _openPartner,
            ),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.draft,
    required this.onTap,
    required this.onHelpTypeTap,
    required this.onServiceTap,
    required this.onPartnerTap,
  });

  final ServiceCategory category;

  /// Set only when this card is the selected one.
  final ServiceRequestDraft? draft;
  final VoidCallback onTap;
  final ValueChanged<int> onHelpTypeTap;
  final ValueChanged<String> onServiceTap;
  final ValueChanged<Partner> onPartnerTap;

  @override
  Widget build(BuildContext context) {
    final draft = this.draft;
    final selected = draft != null;
    final partner = draft?.partner;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: flowCardDecoration(selected: selected),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Stack(
            children: [
              // Gold accent bar on the selected card.
              if (selected)
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: AppColors.gold),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.mint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        category.icon,
                        size: 19,
                        color: selected ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.label,
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              if (category.isSoon) const _SoonBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.muted,
                            ),
                          ),
                          if (draft != null) ...[
                            const SizedBox(height: 16),
                            const FlowSectionLabel('WHAT KIND OF HELP?'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (
                                  var h = 0;
                                  h < category.helpTypes.length;
                                  h++
                                )
                                  FlowPill(
                                    label: category.helpTypes[h].label,
                                    selected: h == draft.helpTypeIndex,
                                    onTap: () => onHelpTypeTap(h),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const FlowSectionLabel('CHOOSE A SERVICE'),
                            const SizedBox(height: 10),
                            for (final service in draft.helpType!.services)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: FlowPill(
                                  label: service,
                                  selected: service == draft.service,
                                  onTap: () => onServiceTap(service),
                                ),
                              ),
                            if (partner != null) ...[
                              const SizedBox(height: 6),
                              _PartnerBanner(
                                partner: partner,
                                onTap: () => onPartnerTap(partner),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerBanner extends StatelessWidget {
  const _PartnerBanner({required this.partner, required this.onTap});

  final Partner partner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.partnerBg,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.soonBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            link: true,
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                'Booking this yourself? Quick book via ${partner.label} →',
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.partnerInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Or continue below for your Lifestyle Manager to handle it.',
            style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.soonBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.soonBorder),
      ),
      child: const Text(
        'Soon',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.soonInk,
        ),
      ),
    );
  }
}
