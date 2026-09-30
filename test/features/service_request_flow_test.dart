import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padosipro/app.dart';
import 'package:padosipro/core/storage/session_store.dart';
import 'package:padosipro/features/tasks/data/models/request_timing.dart';
import 'package:padosipro/features/tasks/data/models/task_request.dart';
import 'package:padosipro/features/tasks/data/tasks_repository.dart';

class _FakeTasksRepository extends TasksRepository {
  _FakeTasksRepository() : super(Dio());

  final calls = <Map<String, Object?>>[];

  @override
  Future<TaskRequest> createTaskRequest({
    required String category,
    required String helpType,
    required String service,
    required RequestTiming timing,
    DateTime? day,
    TimeSlot? slot,
    required String details,
  }) async {
    calls.add({
      'category': category,
      'helpType': helpType,
      'service': service,
      'timing': timing,
      'day': day,
      'slot': slot,
      'details': details,
    });
    return TaskRequest(id: 't1', category: category, status: 'pending');
  }
}

const _session = Session(
  accessToken: 'access',
  refreshToken: 'refresh',
  user: AppUser(id: 'u1', phone: '+919876543210', email: 'y@example.com'),
  needsProfile: false,
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<_FakeTasksRepository> openHome(WidgetTester tester) async {
    final repo = _FakeTasksRepository();
    final container = ProviderContainer(
      overrides: [tasksRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).start(_session);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PadosiProApp(),
      ),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Home tile → service → when → details sends the request', (
    tester,
  ) async {
    final repo = await openHome(tester);

    await tap(tester, find.text('Home Services'));
    // Opened with Home Services and its first help type selected.
    expect(find.text('WHAT KIND OF HELP?'), findsOneWidget);
    expect(find.text('Plumbing'), findsOneWidget);

    // Continue does nothing until a service is chosen.
    await tap(tester, find.text('Continue'));
    expect(find.text('When do you need this?'), findsNothing);

    // Changing the help type clears the chosen service.
    await tap(tester, find.text('Plumbing'));
    await tap(tester, find.text('Cleaning'));
    expect(find.text('Plumbing'), findsNothing);
    await tap(tester, find.text('Continue'));
    expect(find.text('When do you need this?'), findsNothing);

    await tap(tester, find.text('Water tank cleaning'));
    await tap(tester, find.text('Continue'));
    expect(find.text('When do you need this?'), findsOneWidget);

    // Scheduled needs a day and a time window before Next works.
    await tap(tester, find.text('Scheduled'));
    await tap(tester, find.text('Today'));
    await tap(tester, find.text('Next'));
    expect(find.text('Tell us a little more'), findsNothing);
    await tap(tester, find.text('Morning · 8–12'));
    await tap(tester, find.text('Next'));

    expect(find.text('Tell us a little more'), findsOneWidget);
    expect(find.text('Home Services · Water tank cleaning'), findsOneWidget);
    expect(find.text('Today, Morning'), findsOneWidget);

    // Back keeps the selections.
    await tap(tester, find.text('Back'));
    expect(find.text('TIME WINDOW'), findsOneWidget);
    await tap(tester, find.text('Next'));

    await tap(tester, find.text('Leave it with us'));
    expect(repo.calls, isEmpty);

    await tester.enterText(find.byType(TextField), '  Tank on the terrace  ');
    await tap(tester, find.text('Leave it with us'));

    expect(repo.calls, hasLength(1));
    final now = DateTime.now();
    expect(repo.calls.single, {
      'category': 'Home Services',
      'helpType': 'Cleaning',
      'service': 'Water tank cleaning',
      'timing': RequestTiming.scheduled,
      'day': DateTime(now.year, now.month, now.day),
      'slot': TimeSlot.morning,
      'details': 'Tank on the terrace',
    });
    expect(find.text('Water tank cleaning request sent'), findsOneWidget);
  });

  testWidgets('a partner service shows the quick-book banner', (tester) async {
    await openHome(tester);

    await tap(tester, find.text('Travel & Tourism'));
    expect(find.textContaining('Quick book'), findsNothing);

    await tap(tester, find.text('Flights'));
    expect(
      find.text('Booking this yourself? Quick book via MakeMyTrip →'),
      findsOneWidget,
    );

    // Deselecting the service hides it again.
    await tap(tester, find.text('Flights'));
    expect(find.textContaining('Quick book'), findsNothing);
  });
}
