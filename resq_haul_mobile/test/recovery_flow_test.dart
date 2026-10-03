import 'package:flutter_test/flutter_test.dart';
import 'package:resq_haul_mobile/core/recovery_controller.dart';
import 'package:resq_haul_mobile/data/repository.dart';
import 'package:resq_haul_mobile/domain/models.dart';

void main() {
  late RecoveryController c;
  setUp(() async {
    c = RecoveryController(MemoryRecoveryRepository());
    await c.initialize();
  });
  test(
    'Donation requires acceptance, assignment, pickup, and recipient confirmation',
    () {
      final b = c.batches.first;
      expect(() => c.pickup(b, true), throwsStateError);
      c.accept(b, receivers.first);
      c.assign(b);
      c.pickup(b, true);
      expect(() => c.deliver(b, 'wrong', true), throwsStateError);
      expect(() => c.deliver(b, '2468', false), throwsStateError);
      c.deliver(b, '2468', true);
      expect(c.donated, 10);
      expect(b.receipt, 'RCPT-RH-101');
      expect(() => c.deliver(b, '2468', true), throwsStateError);
      expect(c.donated, 10);
    },
  );
  test('Delay blocks delivery; alternate route preserves recipient', () {
    final b = c.batches[1];
    expect(b.eligible(c.clock), false);
    expect(() => c.deliver(b, '2468', true), throwsStateError);
    final recipient = b.recipient;
    c.reroute(b);
    expect(b.recipient, recipient);
    expect(() => c.reroute(b), throwsStateError);
    expect(b.eligible(c.clock), true);
    c.deliver(b, '2468', true);
    expect(c.donated, 20);
  });
  test('Alternate recipient reserves capacity without repeating pickup', () {
    final b = c.batches[1];
    c.accept(b, receivers[1], switchRecipient: true);
    expect(b.stage, Stage.transit);
    expect(b.pickedUp, true);
    expect(b.switched, true);
    expect(c.recipientLoad(receivers[1].name), 20);
    final other = c.batches.first;
    expect(c.canMatch(other, receivers[1]), false);
    expect(() => c.accept(other, receivers[1]), throwsStateError);
  });
  test('Expiry closes donation and preserves driver custody', () {
    final b = c.batches[1];
    c.advance(30);
    expect(b.stage, Stage.waste);
    expect(b.pickedUp, true);
    expect(() => c.reroute(b), throwsStateError);
    expect(() => c.deliver(b, '2468', true), throwsStateError);
    expect(c.donated, 0);
  });
  test(
    'Facility accepts only suitable material and measured loads count once',
    () {
      final b = c.batches[3];
      c.advance(5);
      expect(b.stage, Stage.waste);
      expect(
        () => c.assess(b, facilities[1], 'Separated organics', true),
        throwsStateError,
      );
      c.assess(b, facilities.first, 'Plant scraps', true);
      c.collect(b);
      expect(c.recovered, 0);
      c.receive(b, 11.5, true);
      expect(c.recovered, 0);
      c.process(b);
      expect(() => c.complete(b, false), throwsStateError);
      c.complete(b, true);
      expect(c.recovered, 11.5);
      expect(() => c.complete(b, true), throwsStateError);
    },
  );
  test('Rejected load remains uncounted and can be reassessed', () {
    final b = c.batches[3];
    c.advance(5);
    c.assess(b, facilities.first, 'Plant scraps', true);
    c.collect(b);
    c.receive(b, 12, false);
    expect(b.stage, Stage.rejected);
    expect(c.recovered, 0);
    c.assess(b, facilities[1], 'Plant scraps', true);
    expect(b.stage, Stage.assessed);
  });
  test(
    'Offline and non-full bins are skipped; repeated collection cannot duplicate',
    () {
      c.toggleSensor(c.bins.first);
      c.collectBins();
      expect(c.bins.first.fill, 94);
      expect(c.bins[1].fill, 0);
      expect(c.bins[2].fill, 42);
      expect(c.batches.where((b) => b.stage == Stage.waste).length, 1);
      expect(() => c.collectBins(), throwsStateError);
      expect(c.recovered, 0);
    },
  );
  test('Session survives repository reload', () async {
    c.advance(15);
    c.changeRole(AppRole.recovery);
    c.toggleNeed('Produce');
    await c.flush();
    final restored = RecoveryController(c.repository);
    await restored.initialize();
    expect(restored.clock, 15);
    expect(restored.role, AppRole.recovery);
    expect(restored.needs, contains('Produce'));
    expect(restored.batches[3].stage, Stage.waste);
  });
  test('Sales revenue counts only after confirmed delivery', () {
    final b = c.batches[2];
    c.accept(b, receivers[1]);
    c.assign(b);
    c.pickup(b, true);
    expect(c.revenue, 0);
    c.deliver(b, '2468', true);
    expect(c.revenue, 25);
    expect(c.sold, 5);
  });
  test(
    'Collection runs retain source, group facilities and prevent repeat pickup',
    () {
      c.collectBins();
      final waste = c.batches.where((b) => b.stage == Stage.waste).toList();
      expect(
        waste.map((b) => b.source),
        containsAll(['Tunas Kitchen', 'Kenny’s Bakehouse']),
      );
      for (final b in waste) {
        c.assess(b, facilities.first, 'Separated organics', true);
      }
      final plan = c.collectionPlan(facilities.first.name);
      expect(plan.length, 2);
      expect(plan.first.source, 'Tunas Kitchen');
      c.collectRun(plan);
      expect(c.collectionPlan(facilities.first.name), isEmpty);
      expect(() => c.collectRun(plan), throwsStateError);
      expect(c.recovered, 0);
    },
  );
}
