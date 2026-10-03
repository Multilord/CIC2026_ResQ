import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_haul_mobile/core/recovery_controller.dart';
import 'package:resq_haul_mobile/data/repository.dart';
import 'package:resq_haul_mobile/ui/app.dart';
import 'package:resq_haul_mobile/ui/batch_screen.dart';
import 'package:resq_haul_mobile/ui/create_screen.dart';
import 'package:resq_haul_mobile/ui/design.dart';
import 'package:resq_haul_mobile/ui/collection_screen.dart';

void main() {
  testWidgets('Collection plan and facility assessment sheets fit a phone', (
    t,
  ) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final c = RecoveryController(MemoryRecoveryRepository());
    await c.initialize();
    await t.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: CollectionScreen(controller: c),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    c.advance(15);
    final b = c.batches[3];
    await t.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: BatchScreen(controller: c, batch: b),
      ),
    );
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('Assess & select recovery partner'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('Assess & select recovery partner'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('BSFL'), findsOneWidget);
    expect(find.text('Compost'), findsOneWidget);
    expect(find.text('Biogas'), findsOneWidget);
  });
  Future<RecoveryController> setup(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final c = RecoveryController(MemoryRecoveryRepository());
    await c.initialize();
    return c;
  }

  testWidgets('Four mobile tabs render without overflow', (t) async {
    final c = await setup(t);
    await t.pumpWidget(ResQApp(controller: c));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    for (final label in ['Discover', 'Journeys', 'Impact', 'Home']) {
      await t.tap(find.text(label).last);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: label);
    }
  });
  testWidgets('Reference delivery and waste screens render at narrow width', (
    t,
  ) async {
    final c = await setup(t);
    for (final b in c.batches) {
      await t.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: BatchScreen(controller: c, batch: b),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.drag(find.byType(ListView), const Offset(0, -500));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    }
    c.advance(90);
    await t.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: BatchScreen(controller: c, batch: c.batches.first),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Listing form renders and requires source condition confirmation',
    (t) async {
      final c = await setup(t);
      await t.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: CreateScreen(controller: c),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.scrollUntilVisible(
        find.text('List for donation'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
      final button = t.widget<FilledButton>(
        find
            .ancestor(
              of: find.text('List for donation'),
              matching: find.byWidgetPredicate((w) => w is FilledButton),
            )
            .first,
      );
      expect(button.onPressed, isNull);
    },
  );
}
