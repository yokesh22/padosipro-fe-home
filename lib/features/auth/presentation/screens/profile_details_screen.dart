import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/profile_notifier.dart';

/// Step 3 (new users only): name is required. The address is optional, but
/// once any address field is filled, flat / unit is required.
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

  // Flat error only shows after a Continue tap, not while typing.
  bool _triedSubmit = false;

  bool get _nameValid => Validators.isValidName(_name.text);
  bool get _addressEntered =>
      [_address, _society, _flat, _notes].any((c) => c.text.trim().isNotEmpty);
  bool get _flatMissing => _addressEntered && _flat.text.trim().isEmpty;
  bool get _formValid => _nameValid && !_flatMissing;

  @override
  void dispose() {
    for (final c in [_name, _address, _society, _flat, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    setState(() => _triedSubmit = true);
    if (!_formValid) return;
    FocusScope.of(context).unfocus();
    ref
        .read(profileProvider.notifier)
        .submit(
          fullName: _name.text,
          flatUnit: _flat.text,
          addressLine: _address.text,
          society: _society.text,
          notes: _notes.text,
        );
  }

  void _onChanged(String _) {
    ref.read(profileProvider.notifier).clearError();
    setState(() {});
  }

  /// Server error shown above Continue; null for 401/404, which end the
  /// session and leave this screen.
  static String? _formErrorFor(Object? error) {
    if (error is! AppException) return null;
    return switch (error.statusCode) {
      401 || 404 => null,
      403 => 'Your account is suspended. Please contact support.',
      _ => error.message,
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (_, next) {
      final status = (next.error as AppException?)?.statusCode;
      if (status == 401 || status == 404) {
        // Root messenger, so it stays visible on the sign-in screen.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Your session has ended. Please sign in again.'),
            ),
          );
      }
    });
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState.isLoading;
    final formError = _formErrorFor(profileState.error);
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
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    onChanged: _onChanged,
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
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    onChanged: _onChanged,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Society / building (optional)',
                    controller: _society,
                    hint: 'Name as on the gate',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    onChanged: _onChanged,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Flat / unit (optional)',
                    controller: _flat,
                    hint: 'e.g. Tower B, 1204',
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    errorText: _triedSubmit && _flatMissing
                        ? 'Add your flat / unit to save this address.'
                        : null,
                    onChanged: _onChanged,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Gate or entry notes (optional)',
                    controller: _notes,
                    hint: 'e.g. Call before arriving',
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    onChanged: _onChanged,
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
                  if (formError != null) ...[
                    Text(
                      formError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else if (!_nameValid) ...[
                    const Text(
                      'Enter your full name to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                  ] else if (_flatMissing) ...[
                    const Text(
                      'Add your flat / unit to save the address.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                  ],
                  PrimaryButton(
                    label: 'Continue',
                    loadingLabel: 'Saving…',
                    enabled: _formValid,
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
