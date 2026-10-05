import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_haul_mobile/data/network_service.dart';
import 'package:resq_haul_mobile/ui/workspace.dart';
import 'package:resq_haul_mobile/ui/design.dart';

void main() {
  testWidgets(
    'combined account chooses a mode before seeing workspace actions',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = NetworkService();
      service.state = {
        'user': {
          'id': 'member',
          'name': 'Community partner',
          'role': 'member',
          'accountRole': 'member',
          'approved': 1,
        },
        'batches': [],
      };
      await tester.pumpWidget(PrototypeApp(service: service));
      expect(find.text('Send food'), findsOneWidget);
      expect(find.text('Receive food'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
      service.dispose();
    },
  );
  testWidgets('Sign-in uses circular branding and no presentation controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = NetworkService();
    await tester.pumpWidget(PrototypeApp(service: service));
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BrandLogo),
        matching: find.byType(ClipOval),
      ),
      findsOneWidget,
    );
    expect(find.text('Kitchen'), findsNothing);
    expect(find.text('Advance 15 min'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Join the recovery.'), findsOneWidget);
    expect(find.text('Send & receive'), findsOneWidget);
    expect(tester.takeException(), isNull);
    service.dispose();
  });
  for (final role in roleNames.keys.where((role) => role != 'member')) {
    testWidgets('$role workspace renders on a narrow phone', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = NetworkService();
      service.state = {
        'user': {
          'id': 'one',
          'name': 'Test partner',
          'role': role,
          'approved': 1,
          'capacity': 100,
          'available': 1,
          'location': 'Kuala Lumpur',
        },
        'batches': [],
        'users': [],
        'events': [],
        'paused': false,
        'geminiConfigured': false,
        'ai': {'status': 'Not run yet'},
      };
      await tester.pumpWidget(PrototypeApp(service: service));
      expect(find.text(roleNames[role]!), findsOneWidget);
      if (role == 'admin') {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(find.text('Automated coordination active'), findsOneWidget);
        expect(find.text('Restart journey timings'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Recoveries'));
      await tester.pumpAndSettle();
      expect(
        find.text(role == 'driver' ? 'Delivery jobs.' : 'Every recovery.'),
        findsOneWidget,
      );
      if (role == 'recipient') {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.text('Find food to receive.'), findsOneWidget);
      }
      await tester.tap(find.text(role == 'driver' ? 'Earnings' : 'Activity'));
      await tester.pumpAndSettle();
      expect(
        find.text(role == 'driver' ? 'Your earnings.' : 'The latest.'),
        findsOneWidget,
      );
      await tester.tap(find.text(role == 'admin' ? 'Manage' : 'Account'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      service.dispose();
    });
  }

  testWidgets(
    'desktop queue retains routine tasks when another needs attention',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = NetworkService();
      service.state = {
        'user': {
          'id': 'driver',
          'name': 'Hauler',
          'role': 'driver',
          'approved': 1,
        },
        'batches': [
          for (var i = 0; i < 2; i++)
            {
              'id': 'RH-$i',
              'name': i == 0 ? 'Urgent collection' : 'Routine collection',
              'stage': 'transit',
              'source': 'Event host',
              'category': 'Meals',
              'kg': 12,
              'location': 'Sentul',
              'eta': 18,
              'deadline': service.now + 3600,
              'incident': i == 0 ? 'Route delay' : null,
            },
        ],
        'users': [],
        'events': [],
      };
      await tester.pumpWidget(PrototypeApp(service: service));
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Urgent collection'), findsOneWidget);
      expect(find.text('Routine collection'), findsOneWidget);
      expect(find.text('1 journey needs attention'), findsOneWidget);
      expect(tester.takeException(), isNull);
      service.dispose();
    },
  );

  testWidgets('route map shows current and faster paths on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: RouteMap(
              origin: 'Sentul Event Hall',
              destination: 'Community Kitchen',
              currentEta: 46,
              alternativeEta: 18,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Current · 46 min'), findsOneWidget);
    expect(find.text('Faster route · 18 min'), findsOneWidget);
    expect(find.text('Sentul Event Hall'), findsOneWidget);
    expect(find.text('Community Kitchen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
