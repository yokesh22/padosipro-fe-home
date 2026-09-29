import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/service_catalog.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/session_store.dart';

/// Step 4: home with search, popular categories and how it works.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();

  /// Confirmation shown after a request is sent from All services.
  String? _toast;

  static const _steps = [
    (
      icon: Icons.chat_bubble_outline,
      title: 'Tell us what you need',
      body: 'In your own words. No forms to hunt through.',
    ),
    (
      icon: Icons.how_to_reg_outlined,
      title: 'Your Lifestyle Manager takes it on',
      body: 'One person who knows your family and follows it through.',
    ),
    (
      icon: Icons.check_circle_outline,
      title: 'You see it done',
      body: 'Updates as things actually happen, with proof when it matters.',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _openServices([int? category]) async {
    setState(() => _toast = null);
    final result = await context.push<String>(Routes.services, extra: category);
    if (result != null && mounted) setState(() => _toast = result);
  }

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(sessionProvider)?.user.firstName ?? '';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            16,
            AppSizes.pagePadding,
            AppSizes.pagePadding,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    firstName.isEmpty ? _greeting : '$_greeting, $firstName',
                    style: textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(Icons.person_outline, color: AppColors.ink),
                  // TODO: open profile; signs out for now (as in the design).
                  onPressed: () => ref.read(sessionProvider.notifier).clear(),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('What do you need help with?', style: textTheme.titleLarge),
            const SizedBox(height: 14),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              // TODO: send free-text requests once the API exists.
              decoration: const InputDecoration(
                hintText: 'AC leaking, cook for weekends...',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('POPULAR WITH FAMILIES LIKE YOURS'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < ServiceCatalog.homeChipCount; i++)
                  _CategoryChip(
                    category: ServiceCatalog.categories[i],
                    onTap: () => _openServices(i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _openServices,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text('Browse everything we do')),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 15),
                  ],
                ),
              ),
            ),
            if (_toast != null) ...[
              const SizedBox(height: 16),
              _RequestSentBanner(message: _toast!),
            ],
            const SizedBox(height: 26),
            const _SectionLabel('HOW PADOSIPRO WORKS'),
            const SizedBox(height: 12),
            for (final step in _steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.icon,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.body,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            const _LifestyleManagerCard(),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.muted,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final ServiceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  category.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestSentBanner extends StatelessWidget {
  const _RequestSentBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.mintBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Pilot LM will reach out shortly to take this forward.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleManagerCard extends StatelessWidget {
  const _LifestyleManagerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Lifestyle Manager',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pilot LM',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 17),
                ),
              ],
            ),
          ),
          TextButton.icon(
            // TODO: open chat with the Lifestyle Manager.
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 17),
            label: const Text('Chat'),
          ),
        ],
      ),
    );
  }
}
