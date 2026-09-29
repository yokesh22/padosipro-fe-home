import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:padosipro/app.dart';

void main() {
  testWidgets('sign-in shows Welcome and validates phone on submit', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PadosiProApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.tap(find.text('Get OTP'));
    await tester.pump();

    expect(find.text('Enter a 10-digit mobile number.'), findsOneWidget);
  });
}
