import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// App logo shown at the top of the auth screens.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Image.asset(
          'assets/images/padosipro-logo.png',
          width: 56,
          height: 56,
        ),
      ),
    );
  }
}
