import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padosipro/app.dart';
import 'package:padosipro/core/storage/session_store.dart';
import 'package:padosipro/features/tasks/data/models/task_request.dart';
import 'package:padosipro/features/tasks/data/tasks_repository.dart';

/// Keeps Home off the network.
class _NoTasksRepository extends TasksRepository {
  _NoTasksRepository() : super(Dio());

  @override
  Future<List<TaskRequest>> getActiveTasks({int limit = 5}) async => [];
}

Session _session({String? society}) => Session(
  accessToken: 'access',
  refreshToken: 'refresh',
  user: AppUser(
    id: 'u1',
    phone: '+919876543210',
    email: 'yokesh@gmail.com',
    fullName: 'yokesh',
    defaultAddress: UserAddress(
      id: 'a1',
      flatUnit: 'Block 44',
      addressLine: 'Outer Ring Road, Bangalore',
      society: society,
    ),
  ),
  needsProfile: false,
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<ProviderContainer> openAccount(
    WidgetTester tester,
    Session session,
  ) async {
    final container = ProviderContainer(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(_NoTasksRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).start(session);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PadosiProApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('profile icon opens Account with the user and LM details', (
    tester,
  ) async {
    await openAccount(tester, _session(society: 'Candeza'));

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
    expect(find.text('yokesh@gmail.com'), findsOneWidget);
    expect(find.text('Pilot LM'), findsOneWidget);
    expect(find.text('Mumbai'), findsOneWidget);
    expect(find.text('yokesh'), findsOneWidget);
    expect(find.text('Outer Ring Road, Bangalore'), findsOneWidget);
    expect(find.text('Society: Candeza'), findsOneWidget);
    expect(find.text('Flat / unit: Block 44'), findsOneWidget);
  });

  testWidgets('an empty society line is hidden', (tester) async {
    await openAccount(tester, _session());

    expect(find.textContaining('Society:'), findsNothing);
    expect(find.text('Flat / unit: Block 44'), findsOneWidget);
  });

  testWidgets('Back returns to Home', (tester) async {
    await openAccount(tester, _session());

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsNothing);
    expect(find.byTooltip('Profile'), findsOneWidget);
  });

  testWidgets('Sign out clears the session and shows Sign up', (tester) async {
    final container = await openAccount(tester, _session());

    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(container.read(sessionProvider), isNull);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
