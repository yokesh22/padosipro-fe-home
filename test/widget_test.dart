import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:padosipro/app.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PadosiProApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('sign-up shows Welcome and validates phone on submit', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Welcome'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.tap(find.text('Get OTP'));
    await tester.pump();

    expect(find.text('Enter a 10-digit mobile number.'), findsOneWidget);
  });

  testWidgets('sign-up validates password and confirm password', (
    tester,
  ) async {
    await pumpApp(tester);
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(2), 'short');
    await tester.enterText(fields.at(3), 'other');
    await tester.tap(find.text('Get OTP'));
    await tester.pump();

    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(find.text("Passwords don't match."), findsOneWidget);

    await tester.enterText(fields.at(2), 'longenough');
    await tester.enterText(fields.at(3), 'longenough');
    await tester.pump();

    expect(find.text('Use at least 8 characters.'), findsNothing);
    expect(find.text('Passwords match'), findsOneWidget);
  });

  testWidgets('Sign in link opens Sign in and Create account returns', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
  });
}
