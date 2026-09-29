import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/sign_in_notifier.dart';

/// Step 1: mobile number + email → Get OTP (OTP is sent to email).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  // Errors only show once a field has been left (or submit was tapped).
  bool _phoneTouched = false;
  bool _emailTouched = false;

  String get _phone => _phoneController.text.replaceAll(RegExp(r'\D'), '');
  String get _email => _emailController.text.trim();
  bool get _phoneValid => Validators.isValidPhone(_phone);
  bool get _emailValid => Validators.isValidEmail(_email);

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus) setState(() => _phoneTouched = true);
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailTouched = true);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_phoneValid || !_emailValid) {
      setState(() {
        _phoneTouched = true;
        _emailTouched = true;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    final sent = await ref
        .read(signInProvider.notifier)
        .sendOtp(phone: _phone, email: _email);
    if (sent && mounted) context.push(Routes.verifyOtp);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signInProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final isLoading = ref.watch(signInProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    final showPhoneError = _phoneTouched && _phone.isNotEmpty && !_phoneValid;
    final showEmailError = _emailTouched && _email.isNotEmpty && !_emailValid;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              20,
              AppSizes.pagePadding,
              AppSizes.pagePadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 20 - AppSizes.pagePadding,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        child: Image.asset(
                          'assets/images/padosipro-logo.png',
                          width: 56,
                          height: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'PadosiPro',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.9,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Welcome', style: textTheme.headlineLarge),
                    const SizedBox(height: 10),
                    Text(
                      "Enter your mobile number and email. We'll send the OTP "
                      'to your email.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Mobile number',
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      height: AppSizes.fieldHeight,
                      icon: Icons.phone_outlined,
                      prefixText: '+91',
                      hint: '98765 43210',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      inputFormatters: [_PhoneFormatter()],
                      errorText: showPhoneError
                          ? 'Enter a 10-digit mobile number.'
                          : null,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      focusNode: _emailFocus,
                      height: AppSizes.fieldHeight,
                      icon: Icons.mail_outline,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      errorText: showEmailError
                          ? "That email doesn't look right."
                          : null,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Get OTP',
                      loadingLabel: 'Sending code…',
                      enabled: _phoneValid && _emailValid,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Digits only, max 10, displayed as `98765 43210`.
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);
    final text = digits.length > 5
        ? '${digits.substring(0, 5)} ${digits.substring(5)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
