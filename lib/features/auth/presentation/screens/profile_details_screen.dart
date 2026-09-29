import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/profile_notifier.dart';

/// Step 3 (new users only): name is required, the rest is optional.
class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _society = TextEditingController();
  final _flat = TextEditingController();
  final _notes = TextEditingController();

  bool get _nameValid => Validators.isValidName(_name.text);

  @override
  void dispose() {
    for (final c in [_name, _address, _society, _flat, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_nameValid) return;
    FocusScope.of(context).unfocus();
    ref
        .read(profileProvider.notifier)
        .submit(
          name: _name.text,
          address: _address.text,
          society: _society.text,
          flat: _flat.text,
          notes: _notes.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final isLoading = ref.watch(profileProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  20,
                  AppSizes.pagePadding,
                  16,
                ),
                children: [
                  Text('A few details', style: textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(
                    'So your Lifestyle Manager can coordinate visits and '
                    'deliveries smoothly.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Full name',
                    controller: _name,
                    hint: 'As you would like us to use',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Address & area',
                    controller: _address,
                    hint: 'Road, area, landmark',
                    maxLines: 3,
                    height: 92,
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Society / building (optional)',
                    controller: _society,
                    hint: 'Name as on the gate',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Flat / unit (optional)',
                    controller: _flat,
                    hint: 'e.g. Tower B, 1204',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Gate or entry notes (optional)',
                    controller: _notes,
                    hint: 'e.g. Call before arriving',
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                12,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: Color(0x0D000000))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_nameValid) ...[
                    const Text(
                      'Enter your full name to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                  ],
                  PrimaryButton(
                    label: 'Continue',
                    loadingLabel: 'Saving…',
                    enabled: _nameValid,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
