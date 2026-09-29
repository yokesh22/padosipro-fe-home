import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/storage/session_store.dart';
import '../../../../shared/widgets/back_text_button.dart';
import '../providers/assigned_lm_provider.dart';

/// Opened from the profile icon on Home: who is signed in, their LM and
/// address, household, wallet and sign out.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static const _sidePadding = 18.0;

  /// `+919876543210` → `+91 98765 43210`. Anything else is shown as is.
  static String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final local = digits.length == 12 && digits.startsWith('91')
        ? digits.substring(2)
        : digits;
    if (local.length != 10) return phone;
    return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider)?.user;
    final lm = ref.watch(assignedLmProvider);
    // Signed out: the router is already leaving this screen.
    if (user == null) return const Scaffold();

    final address = user.defaultAddress;
    String? nonBlank(String? v) => (v == null || v.trim().isEmpty) ? null : v;
    final addressLines = [
      ?nonBlank(address?.addressLine),
      if (nonBlank(address?.society) case final society?) 'Society: $society',
      if (nonBlank(address?.flatUnit) case final flat?) 'Flat / unit: $flat',
    ];
    final fullName = nonBlank(user.fullName);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(_sidePadding, 8, _sidePadding, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackTextButton(onPressed: () => context.pop()),
            ),
            const SizedBox(height: 12),
            Text('Account', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 20),
            _Card(
              label: 'Signed in as',
              children: [
                Text(
                  _formatPhone(user.phone),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _Muted(user.email),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _Card(
              label: 'Your LM',
              children: [
                Text(
                  lm.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _Muted(lm.city),
                if (fullName != null) ...[
                  const SizedBox(height: 2),
                  _Muted(fullName),
                ],
                if (addressLines.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  for (final line in addressLines) _Muted(line, fontSize: 13),
                ],
              ],
            ),
            const SizedBox(height: 14),
            const _HouseholdRow(),
            const SizedBox(height: 14),
            const _Card(
              label: 'Wallet',
              children: [
                Text(
                  'Coming soon',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                _Muted(
                  "Wallet top-up isn't turned on yet. Your Lifestyle Manager "
                  'can still handle requests and send you the bill directly '
                  'in the meantime.',
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                // The router sends a signed-out user to Sign up.
                onPressed: () => ref.read(sessionProvider.notifier).clear(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.signOutBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
  border: Border.all(color: AppColors.border),
);

class _Muted extends StatelessWidget {
  const _Muted(this.text, {this.fontSize = 14.5});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.45,
        color: AppColors.muted,
      ),
    );
  }
}

class _HouseholdRow extends StatelessWidget {
  const _HouseholdRow();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // TODO: open the Household screen once it exists.
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.all(19),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.mint,
                child: Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Household',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    _Muted('Family members your LM should know about'),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}
