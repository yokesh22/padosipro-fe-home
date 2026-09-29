import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/service_catalog.dart';
import '../../../../shared/widgets/back_text_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/create_task_notifier.dart';

/// Step 5: pick a category, optionally a kind of help, and send a request.
/// Pops with a confirmation message for Home to show.
class AllServicesScreen extends ConsumerStatefulWidget {
  const AllServicesScreen({super.key, this.initialCategory});

  final int? initialCategory;

  @override
  ConsumerState<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends ConsumerState<AllServicesScreen> {
  static const _categories = ServiceCatalog.categories;

  final _cardKeys = List.generate(_categories.length, (_) => GlobalKey());
  int? _selected;
  String? _subType;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
    if (_selected != null) _scrollTo(_selected!);
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
    if (_selected == index) return;
    setState(() {
      _selected = index;
      _subType = null;
    });
    _scrollTo(index);
  }

  Future<void> _submit() async {
    final index = _selected;
    if (index == null) return;
    final category = _categories[index];
    final created = await ref
        .read(createTaskProvider.notifier)
        .submit(category: category.label, subType: _subType);
    if (created != null && mounted) {
      context.pop('${_subType ?? category.label} request sent');
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
    final isLoading = ref.watch(createTaskProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: BackTextButton(onPressed: () => context.pop()),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'What do you need help with?',
                      style: textTheme.headlineLarge?.copyWith(fontSize: 27),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Pick a category, then choose a service. You can add '
                      'details next.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    for (var i = 0; i < _categories.length; i++)
                      Padding(
                        key: _cardKeys[i],
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CategoryCard(
                          category: _categories[i],
                          selected: _selected == i,
                          selectedSubType: _selected == i ? _subType : null,
                          onTap: () => _selectCategory(i),
                          onSubTypeTap: (sub) => setState(
                            () => _subType = _subType == sub ? null : sub,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                16,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: Color(0x14000000))),
              ),
              child: PrimaryButton(
                label: 'Continue',
                loadingLabel: 'Sending…',
                enabled: _selected != null,
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.selectedSubType,
    required this.onTap,
    required this.onSubTypeTap,
  });

  final ServiceCategory category;
  final bool selected;
  final String? selectedSubType;
  final VoidCallback onTap;
  final ValueChanged<String> onSubTypeTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusLg);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedBg : AppColors.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
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
                          if (selected) ...[
                            const SizedBox(height: 14),
                            const Text(
                              'WHAT KIND OF HELP?',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final sub in category.subTypes)
                                  _SubTypePill(
                                    label: sub,
                                    selected: sub == selectedSubType,
                                    onTap: () => onSubTypeTap(sub),
                                  ),
                              ],
                            ),
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

class _SubTypePill extends StatelessWidget {
  const _SubTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
