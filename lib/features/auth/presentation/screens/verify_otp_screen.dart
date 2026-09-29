import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/back_text_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/sign_in_notifier.dart';
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

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendAfter);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  void _resend() {
    _otpController.clear();
    _startCountdown();
    ref.read(verifyOtpProvider.notifier).resend();
  }

  void _submit() {
    if (!_otpValid) return;
    ref.read(verifyOtpProvider.notifier).verify(_otpController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(verifyOtpProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final isLoading = ref.watch(verifyOtpProvider).isLoading;
    final email = ref.watch(pendingLoginProvider)?.email ?? '';
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
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      if (_secondsLeft > 0)
                        Text.rich(
                          TextSpan(
                            text: 'Resend code in ',
                            children: [
                              TextSpan(
                                text:
                                    '0:${_secondsLeft.toString().padLeft(2, '0')}',
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
                enabled: _otpValid,
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
