import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/sign_up_notifier.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_logo.dart';
import '../widgets/password_field.dart';

/// New users: mobile, email and password → Get OTP (OTP is sent to email).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // Errors only show once a field has been left (or submit was tapped).
  bool _phoneTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  String get _phone => _phoneController.text.replaceAll(RegExp(r'\D'), '');
  String get _email => _emailController.text.trim();
  String get _password => _passwordController.text;
  String get _confirm => _confirmController.text;
  bool get _phoneValid => Validators.isValidPhone(_phone);
  bool get _emailValid => Validators.isValidEmail(_email);
  bool get _passwordValid => Validators.isValidPassword(_password);
  bool get _confirmValid => _confirm.isNotEmpty && _confirm == _password;
  bool get _formValid =>
      _phoneValid && _emailValid && _passwordValid && _confirmValid;

  @override
  void initState() {
    super.initState();
    _onBlur(_phoneFocus, () => _phoneTouched = true);
    _onBlur(_emailFocus, () => _emailTouched = true);
    _onBlur(_passwordFocus, () => _passwordTouched = true);
    _onBlur(_confirmFocus, () => _confirmTouched = true);
  }

  void _onBlur(FocusNode node, VoidCallback markTouched) {
    node.addListener(() {
      if (!node.hasFocus) setState(markTouched);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formValid) {
      setState(() {
        _phoneTouched = true;
        _emailTouched = true;
        _passwordTouched = true;
        _confirmTouched = true;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    final sent = await ref
        .read(signUpProvider.notifier)
        .sendOtp(phone: _phone, email: _email, password: _password);
    if (sent && mounted) context.push(Routes.verifyOtp);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signUpProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final isLoading = ref.watch(signUpProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    final showPhoneError = _phoneTouched && _phone.isNotEmpty && !_phoneValid;
    final showEmailError = _emailTouched && _email.isNotEmpty && !_emailValid;
    final showPasswordError =
        _passwordTouched && _password.isNotEmpty && !_passwordValid;
    final confirmChecked = _confirmTouched && _confirm.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  20,
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                ),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthLogo(),
                      const SizedBox(height: 20),
                      Text('Welcome', style: textTheme.headlineLarge),
                      const SizedBox(height: 10),
                      Text(
                        "Create your account. We'll send an OTP to your "
                        'email to verify it.',
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
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        errorText: showEmailError
                            ? "That email doesn't look right."
                            : null,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 20),
                      PasswordField(
                        label: 'Password',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hint: 'At least 8 characters',
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        errorText: showPasswordError
                            ? 'Use at least 8 characters.'
                            : null,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _confirmFocus.requestFocus(),
                      ),
                      const SizedBox(height: 20),
                      PasswordField(
                        label: 'Confirm password',
                        controller: _confirmController,
                        focusNode: _confirmFocus,
                        hint: 'Re-enter password',
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        errorText: confirmChecked && !_confirmValid
                            ? "Passwords don't match."
                            : null,
                        successText: confirmChecked && _confirmValid
                            ? 'Passwords match'
                            : null,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AuthFooter(
              showDivider: true,
              button: PrimaryButton(
                label: 'Get OTP',
                loadingLabel: 'Sending code…',
                enabled: _formValid,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              prompt: 'Already have an account?',
              actionLabel: 'Sign in',
              onAction: () => context.push(Routes.signIn),
            ),
          ],
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
