import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_haul_mobile/data/network_service.dart';
import 'package:resq_haul_mobile/ui/workspace.dart';
import 'package:resq_haul_mobile/ui/design.dart';

void main() {
  testWidgets('Sign-in uses circular branding and no demo controls', (
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
    expect(find.text('Sender'), findsOneWidget);
    expect(tester.takeException(), isNull);
    service.dispose();
  });
  for (final role in roleNames.keys) {
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
        expect(find.text('Local demo automation active'), findsOneWidget);
        expect(find.text('Reset demo data and timings'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Recoveries'));
      await tester.pumpAndSettle();
      expect(find.text('Every recovery.'), findsOneWidget);
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      expect(find.text('The latest.'), findsOneWidget);
      await tester.tap(find.text(role == 'admin' ? 'Manage' : 'Account'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      service.dispose();
    });
  }
}
