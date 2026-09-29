import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/back_text_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/auth_response.dart';
import '../providers/sign_up_notifier.dart';
import '../providers/verify_otp_notifier.dart';
import '../widgets/otp_input.dart';

/// Step 2: enter the 6-digit code sent to email.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const _resendAfter = 30;

  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendAfter;

  bool get _otpValid => Validators.isValidOtp(_otpController.text);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  /// The timer is display-only; the server enforces the real cooldown.
  void _startCountdown([int seconds = _resendAfter]) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    await ref.read(resendOtpProvider.notifier).resend();
    if (!mounted) return;

    final result = ref.read(resendOtpProvider);
    final error = result.error;
    if (error is ResendOtpException && error.retryAfterSeconds != null) {
      // Too soon: trust the server's remaining cooldown.
      _startCountdown(error.retryAfterSeconds!);
      return;
    }
    if (error != null) {
      _showSnackBar(error.toString());
      return;
    }
    _otpController.clear();
    _startCountdown();
    _showSnackBar(
      'A new code has been sent to your email. Use the code from the newest '
      'email.',
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() {
    if (!_otpValid) return;
    FocusScope.of(context).unfocus();
    ref.read(verifyOtpProvider.notifier).verify(_otpController.text);
  }

  void _onOtpChanged(String _) {
    ref.read(verifyOtpProvider.notifier).clearError();
    setState(() {});
  }

  static String _messageFor(OtpVerificationException error) =>
      switch (error.failure) {
        OtpFailure.invalidCode => 'Incorrect code. Check it and try again.',
        OtpFailure.expired =>
          'This code has expired or was already used. Request a new one.',
        OtpFailure.tooManyAttempts => 'Too many attempts. Request a new code.',
        OtpFailure.suspended =>
          'Your account is suspended. Please contact support.',
        OtpFailure.other => error.message,
      };

  @override
  Widget build(BuildContext context) {
    // Without a usable code the user can't continue, so allow resend now.
    ref.listen(verifyOtpProvider, (_, next) {
      final failure = (next.error as OtpVerificationException?)?.failure;
      if (failure == OtpFailure.expired ||
          failure == OtpFailure.tooManyAttempts) {
        _startCountdown(0);
      }
    });
    final isResending = ref.watch(resendOtpProvider).isLoading;
    final verifyState = ref.watch(verifyOtpProvider);
    final isLoading = verifyState.isLoading;
    final error = verifyState.error is OtpVerificationException
        ? verifyState.error! as OtpVerificationException
        : null;
    final failure = error?.failure;
    // A used-up code or suspended account can't be retried.
    final locked =
        failure == OtpFailure.tooManyAttempts ||
        failure == OtpFailure.suspended;
    final email = ref.watch(pendingSignUpProvider)?.email ?? '';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            8,
            AppSizes.pagePadding,
            AppSizes.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackTextButton(onPressed: () => context.pop()),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        child: Image.asset(
                          'assets/images/padosipro-logo.png',
                          width: 56,
                          height: 56,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Enter OTP', style: textTheme.headlineLarge),
                      const SizedBox(height: 10),
                      Text(
                        "We've sent a code to the email on your account "
                        '(${Validators.maskEmail(email)}). It expires in 10 '
                        'minutes.',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      Text('6-digit code', style: textTheme.labelMedium),
                      const SizedBox(height: 8),
                      OtpInput(
                        controller: _otpController,
                        enabled: !locked && !isLoading,
                        hasError: error != null,
                        onChanged: _onOtpChanged,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _messageFor(error),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (failure == OtpFailure.suspended)
                        const SizedBox.shrink()
                      else if (isResending)
                        Text('Sending a new code…', style: textTheme.bodyMedium)
                      else if (_secondsLeft > 0)
                        Text.rich(
                          TextSpan(
                            text: 'Resend code in ',
                            children: [
                              TextSpan(
                                text:
                                    '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          style: textTheme.bodyMedium,
                        )
                      else
                        GestureDetector(
                          onTap: _resend,
                          child: const Text(
                            'Resend code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Verify',
                loadingLabel: 'Verifying…',
                enabled: _otpValid && !locked,
                isLoading: isLoading,
                onPressed: locked ? () {} : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
