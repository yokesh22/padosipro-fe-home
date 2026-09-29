import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/back_text_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/sign_in_notifier.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_logo.dart';
import '../widgets/password_field.dart';

/// Returning users: email + password → Home. Never goes through OTP.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // Errors only show once a field has been left (or submit was tapped).
  bool _emailTouched = false;

  String get _email => _emailController.text.trim();
  String get _password => _passwordController.text;
  bool get _emailValid => Validators.isValidEmail(_email);
  bool get _formValid => _emailValid && _password.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailTouched = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Back to Welcome / Sign up, which is normally underneath this screen.
  void _toSignUp() =>
      context.canPop() ? context.pop() : context.go(Routes.signUp);

  Future<void> _submit() async {
    if (!_formValid) {
      setState(() => _emailTouched = true);
      return;
    }
    FocusScope.of(context).unfocus();
    // On success the session starts and the router redirects to Home.
    await ref
        .read(signInProvider.notifier)
        .signIn(email: _email, password: _password);
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

    final showEmailError = _emailTouched && _email.isNotEmpty && !_emailValid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  8,
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                ),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BackTextButton(onPressed: _toSignUp),
                      ),
                      const SizedBox(height: 16),
                      const AuthLogo(),
                      const SizedBox(height: 20),
                      Text('Sign in', style: textTheme.headlineLarge),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome back. Use the email and password you '
                        'signed up with.',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
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
                        hint: 'Your password',
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          // TODO: forgot-password flow.
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AuthFooter(
              button: PrimaryButton(
                label: 'Sign in',
                loadingLabel: 'Signing in…',
                enabled: _formValid,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              prompt: 'New to PadosiPro?',
              actionLabel: 'Create account',
              onAction: _toSignUp,
            ),
          ],
        ),
      ),
    );
  }
}
