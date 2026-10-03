import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/repository.dart';
import '../domain/models.dart';

class RecoveryController extends ChangeNotifier {
  RecoveryController(this.repository);
  final RecoveryRepository repository;
  int clock = 0;
  AppRole role = AppRole.kitchen;
  List<Batch> batches = [];
  List<SmartBin> bins = [];
  List<String> needs = ['Rice', 'Bread'];
  List<String> notices = [];
  Set<String> readNotices = {};
  String? persistenceError;
  Future<void> _pending = Future.value();
  Future<void> initialize() async {
    try {
      final data = await repository.load();
      if (data != null) {
        _restore(data);
        return;
      }
    } catch (_) {
      persistenceError =
          'Saved data could not be loaded. A fresh demo is available.';
    }
    _seed();
  }

  void _seed() {
    clock = 0;
    role = AppRole.kitchen;
    needs = ['Rice', 'Bread'];
    readNotices = {};
    batches = [
      Batch(
        id: 'RH-101',
        name: 'A little extra. A lot of good.',
        category: 'Rice',
        kg: 10,
        deadline: 65,
        storage: 'Hot-held',
        allergens: 'None declared',
      ),
      Batch(
        id: 'RH-102',
        name: 'Lunch for the community',
        category: 'Meals',
        kg: 20,
        deadline: 30,
        stage: Stage.transit,
        recipient: 'Community Kitchen',
        driver: 'Raju',
        pickedUp: true,
        delay: 15,
        history: [
          'Donation listed by Tunas Kitchen',
          'Community Kitchen accepted 20 kg',
          'Raju assigned; 60 kg vehicle capacity',
          'Pickup confirmed; food in transit',
        ],
      ),
      Batch(
        id: 'RH-103',
        name: 'Bakery’s last batch',
        category: 'Bread',
        kg: 5,
        deadline: 90,
        donate: false,
        price: 25,
        source: 'Kenny’s Bakehouse',
        storage: 'Ambient, packed',
        allergens: 'Wheat, dairy',
      ),
      Batch(
        id: 'RH-104',
        name: 'End-of-service vegetables',
        category: 'Produce',
        kg: 12,
        deadline: 5,
        source: 'Pasar Fresh',
        storage: 'Chilled',
      ),
    ];
    bins = [
      SmartBin('BIN-01', 'Tunas Kitchen', 94),
      SmartBin('BIN-02', 'Kenny’s Bakehouse', 91),
      SmartBin('BIN-03', 'Pasar Fresh', 42),
    ];
    notices = [
      'A delivery needs attention: RH-102 has a shrinking recovery window.',
      'Rice and bread match your community needs.',
    ];
  }

  void _restore(Map<String, dynamic> j) {
    clock = j['clock'];
    role = AppRole.values.byName(j['role']);
    batches = (j['batches'] as List)
        .map((x) => Batch.fromJson(Map<String, dynamic>.from(x)))
        .toList();
    bins = (j['bins'] as List)
        .map((x) => SmartBin.fromJson(Map<String, dynamic>.from(x)))
        .toList();
    needs = List<String>.from(j['needs']);
    notices = List<String>.from(j['notices']);
    readNotices = Set<String>.from(j['readNotices'] ?? []);
  }

  Map<String, dynamic> toJson() => {
    'version': 2,
    'clock': clock,
    'role': role.name,
    'batches': batches.map((x) => x.toJson()).toList(),
    'bins': bins.map((x) => x.toJson()).toList(),
    'needs': needs,
    'notices': notices,
    'readNotices': readNotices.toList(),
  };
  void _commit() {
    final snapshot = jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>;
    _pending = _pending
        .then((_) => repository.save(snapshot))
        .then((_) {
          if (persistenceError != null) {
            persistenceError = null;
            notifyListeners();
          }
        })
        .catchError((Object e) {
          persistenceError =
              'Changes are in memory but could not be saved on this device.';
          notifyListeners();
        });
    notifyListeners();
  }

  Future<void> flush() => _pending;
  void reset() {
    _seed();
    _commit();
  }

  void changeRole(AppRole r) {
    role = r;
    _commit();
  }

  int get unread => notices.where((n) => !readNotices.contains(n)).length;
  void markRead() {
    readNotices.addAll(notices);
    _commit();
  }

  void toggleNeed(String n) {
    needs.contains(n) ? needs.remove(n) : needs.add(n);
    _commit();
  }

  double get donated => batches
      .where((b) => b.stage == Stage.delivered && b.donate)
      .fold(0, (a, b) => a + b.kg);
  double get sold => batches
      .where((b) => b.stage == Stage.delivered && !b.donate)
      .fold(0, (a, b) => a + b.kg);
  double get recovered => batches
      .where((b) => b.stage == Stage.completed)
      .fold(0, (a, b) => a + b.measuredKg);
  double get revenue => batches
      .where((b) => b.stage == Stage.delivered && !b.donate)
      .fold(0, (a, b) => a + b.price);
  List<Batch> get urgent =>
      batches.where((b) => b.stage.edible && !b.eligible(clock)).toList();
  void _event(Batch b, String text) {
    b.history.add('+$clock min · $text');
    notices.insert(0, '${b.id} · $text');
  }

  void _require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  void advance([int minutes = 15]) {
    _require(minutes > 0, 'Time must advance.');
    clock += minutes;
    for (final b in batches) {
      if (b.stage.edible && b.remaining(clock) == 0) {
        b.stage = Stage.waste;
        _event(
          b,
          'Edible recovery closed. ${b.pickedUp ? 'Driver retains custody for waste assessment.' : 'Kitchen retains custody for waste assessment.'}',
        );
      }
    }
    _commit();
  }

  Batch create({
    required String name,
    required String category,
    required double kg,
    required int window,
    required bool donate,
    required double price,
    required String storage,
    required String allergens,
    bool waste = false,
    String source = 'Tunas Kitchen',
  }) {
    _require(
      name.trim().isNotEmpty && kg > 0 && kg <= 100,
      'Enter a name and a quantity between 0 and 100 kg.',
    );
    _require(
      waste || window >= 5,
      'Recovery window must be at least 5 minutes.',
    );
    _require(donate || price > 0, 'A sale needs a positive total price.');
    var next = 105;
    while (batches.any((b) => b.id == 'RH-$next')) {
      next++;
    }
    final b = Batch(
      id: 'RH-$next',
      name: name.trim(),
      source: source,
      category: category,
      kg: kg,
      deadline: clock + window,
      donate: donate,
      price: donate ? 0 : price,
      storage: storage,
      allergens: allergens,
      stage: waste ? Stage.waste : Stage.listed,
      createdAt: clock,
      history: [
        waste
            ? 'Organic scraps separated at source'
            : 'Kitchen confirmed food condition and handling details',
      ],
    );
    batches.insert(0, b);
    _event(
      b,
      waste
          ? 'Waste assessment requested'
          : 'New ${donate ? 'donation' : 'sale'} listed',
    );
    if (!waste && needs.contains(category)) {
      notices.insert(
        0,
        'Demand match: ${b.kg} kg of $category available at ${b.source}.',
      );
    }
    _commit();
    return b;
  }

  double recipientLoad(String name) => batches
      .where(
        (b) =>
            b.recipient == name &&
            [Stage.accepted, Stage.assigned, Stage.transit].contains(b.stage),
      )
      .fold(0, (a, b) => a + b.kg);
  bool canMatch(Batch b, Receiver r) =>
      r.categories.contains(b.category) &&
      r.capacity -
              recipientLoad(r.name) +
              (b.recipient == r.name && b.stage != Stage.listed ? b.kg : 0) >=
          b.kg &&
      b.eligible(clock, km: r.km, fresh: true);
  void accept(Batch b, Receiver r, {bool switchRecipient = false}) {
    _require(
      switchRecipient
          ? [Stage.accepted, Stage.assigned, Stage.transit].contains(b.stage)
          : b.stage == Stage.listed,
      'This batch cannot be accepted at this stage.',
    );
    _require(
      canMatch(b, r),
      'Recipient capacity or recovery window is insufficient.',
    );
    b.recipient = r.name;
    b.distance = r.km;
    b.delay = 0;
    if (switchRecipient) {
      b.switched = true;
      b.donate = true;
      b.price = 0;
    } else {
      b.stage = Stage.accepted;
    }
    _event(
      b,
      '${r.name} confirmed acceptance${switchRecipient ? '; destination updated; converted to donation' : ''}',
    );
    _commit();
  }

  void assign(Batch b) {
    _require(
      b.stage == Stage.accepted && b.eligible(clock),
      'Accept a viable recipient first.',
    );
    final load = batches
        .where(
          (x) =>
              x.driver == 'Raju' &&
              [Stage.assigned, Stage.transit].contains(x.stage),
        )
        .fold<double>(0, (a, x) => a + x.kg);
    _require(
      load + b.kg <= 60,
      'Raju’s 60 kg capacity is fully assigned. Complete an existing delivery first.',
    );
    b.driver = 'Raju';
    b.stage = Stage.assigned;
    _event(b, 'Raju assigned; vehicle capacity checked');
    _commit();
  }

  void pickup(Batch b, bool conditionConfirmed) {
    _require(
      b.stage == Stage.assigned && b.eligible(clock) && conditionConfirmed,
      'Pickup requires a viable route and condition confirmation.',
    );
    b.stage = Stage.transit;
    b.pickedUp = true;
    _event(b, 'Pickup confirmed; packed food transferred to driver');
    _commit();
  }

  void conditions(
    Batch b, {
    required int delay,
    required double traffic,
    required int temperature,
  }) {
    _require(b.stage.edible, 'Closed batches cannot be rerouted.');
    b.delay = delay;
    b.traffic = traffic;
    b.temperature = temperature;
    _event(
      b,
      b.eligible(clock)
          ? 'Travel conditions updated'
          : 'Delay detected; delivery at risk',
    );
    _commit();
  }

  bool canReroute(Batch b) =>
      !b.rerouted &&
      [Stage.accepted, Stage.assigned, Stage.transit].contains(b.stage) &&
      b.eligible(clock, km: b.distance * .65, fresh: true);
  void reroute(Batch b) {
    _require(canReroute(b), 'No alternate route fits the remaining window.');
    b.distance *= .65;
    b.delay = 0;
    b.rerouted = true;
    _event(b, 'Alternate route confirmed to SAME recipient');
    _commit();
  }

  void deliver(Batch b, String code, bool conditionConfirmed) {
    _require(
      b.stage == Stage.transit && b.eligible(clock),
      'Delivery is blocked at this stage or outside the recovery window.',
    );
    _require(
      code == '2468' && conditionConfirmed,
      'Confirm received food condition and use demo code 2468.',
    );
    b.stage = Stage.delivered;
    b.receipt = 'RCPT-${b.id}';
    _event(
      b,
      'Recipient confirmed handover; ${b.kg} kg delivered. Receipt ${b.receipt}',
    );
    _commit();
  }

  void rejectFood(Batch b) {
    _require(b.stage.edible, 'This edible pathway is already closed.');
    b.stage = Stage.waste;
    _event(b, 'Food condition rejected; edible recovery closed for assessment');
    _commit();
  }

  double facilityLoad(String name) => batches
      .where(
        (b) =>
            b.facility == name &&
            [
              Stage.assessed,
              Stage.collected,
              Stage.facilityAccepted,
              Stage.processing,
            ].contains(b.stage),
      )
      .fold(0, (a, b) => a + (b.measuredKg > 0 ? b.measuredKg : b.kg));
  void assess(Batch b, Facility f, String material, bool packagingRemoved) {
    _require(
      [Stage.waste, Stage.rejected].contains(b.stage),
      'This batch is not awaiting assessment.',
    );
    _require(
      packagingRemoved && f.materials.contains(material),
      'Remove packaging and select a facility that accepts this material.',
    );
    _require(
      f.capacity - facilityLoad(f.name) >= b.kg,
      'Facility has insufficient available capacity.',
    );
    b.facility = f.name;
    b.material = material;
    b.stage = Stage.assessed;
    b.rejection = '';
    _event(
      b,
      'Assessed as $material; ${f.type} recovery selected, acceptance pending',
    );
    _commit();
  }

  void collect(Batch b) {
    _require(
      b.stage == Stage.assessed,
      'Assess and select a suitable facility first.',
    );
    b.stage = Stage.collected;
    _event(b, 'Hauler collected ${b.kg} kg for ${b.facility}');
    _commit();
  }

  List<Batch> collectionPlan(String facility) {
    // Schematic kilometre coordinates, not a live road-routing service.
    const coordinates = {
      'Tunas Kitchen': (2.0, 1.0),
      'Kenny’s Bakehouse': (1.0, 3.0),
      'Pasar Fresh': (4.0, 2.0),
    };
    final pending = batches
        .where((b) => b.stage == Stage.assessed && b.facility == facility)
        .toList();
    final plan = <Batch>[];
    var point = (0.0, 0.0);
    double load = 0;
    while (pending.isNotEmpty) {
      double distance(Batch b) {
        final next = coordinates[b.source] ?? (3.0, 3.0);
        return (next.$1 - point.$1) * (next.$1 - point.$1) +
            (next.$2 - point.$2) * (next.$2 - point.$2);
      }

      pending.sort((a, b) => distance(a).compareTo(distance(b)));
      final next = pending.removeAt(0);
      if (load + next.kg > 500) {
        continue;
      }
      plan.add(next);
      load += next.kg;
      point = coordinates[next.source] ?? (3.0, 3.0);
    }
    return plan;
  }

  void collectRun(List<Batch> plan) {
    _require(
      plan.isNotEmpty && plan.map((b) => b.id).toSet().length == plan.length,
      'Choose a non-empty collection run.',
    );
    _require(
      plan.every(
        (b) => b.stage == Stage.assessed && b.facility == plan.first.facility,
      ),
      'All stops must be assessed and share a recovery destination.',
    );
    _require(
      plan.fold<double>(0, (sum, b) => sum + b.kg) <= 500,
      'Collection vehicle capacity is 500 kg.',
    );
    for (final b in plan) {
      b.stage = Stage.collected;
      _event(
        b,
        'Collected in a coordinated run to ${b.facility}; facility inspection pending',
      );
    }
    _commit();
  }

  void receive(Batch b, double measured, bool suitable) {
    _require(b.stage == Stage.collected, 'Collect this batch first.');
    _require(
      measured > 0 && measured <= 150,
      'Enter a measured load from 0 to 150 kg.',
    );
    if (!suitable) {
      b.stage = Stage.rejected;
      b.rejection = 'Facility inspection found unsuitable material';
      _event(
        b,
        'Load rejected; reassessment required. Not counted as recovered.',
      );
    } else {
      final f = facilities.firstWhere((f) => f.name == b.facility);
      _require(
        f.capacity - facilityLoad(f.name) + b.kg >= measured,
        'Measured load exceeds facility capacity.',
      );
      b.measuredKg = measured;
      b.stage = Stage.facilityAccepted;
      _event(
        b,
        'Facility weighed and accepted $measured kg; controlled receiving',
      );
    }
    _commit();
  }

  void process(Batch b) {
    _require(
      b.stage == Stage.facilityAccepted,
      'Facility acceptance is required before processing.',
    );
    b.stage = Stage.processing;
    _event(
      b,
      'Processing started; duration represented in demo, not real time',
    );
    _commit();
  }

  void complete(Batch b, bool residueConfirmed) {
    _require(
      b.stage == Stage.processing && residueConfirmed,
      'Confirm processing and residue handling first.',
    );
    b.stage = Stage.completed;
    _event(
      b,
      'Recovery completed; outputs recorded and residue treatment confirmed',
    );
    _commit();
  }

  void sensor(SmartBin b) {
    _require(
      b.online,
      'Sensor offline; verify physical reading before scheduling.',
    );
    b.fill = (b.fill + 7).clamp(0, 100);
    _commit();
  }

  void toggleSensor(SmartBin b) {
    b.online = !b.online;
    _commit();
  }

  void collectBins() {
    final ready = bins.where((b) => b.online && b.fill >= 90).toList();
    _require(ready.isNotEmpty, 'No verified bins at or above 90%.');
    for (final bin in ready) {
      final kg = bin.capacity * bin.fill / 100;
      create(
        name: 'Organics · ${bin.name}',
        source: bin.name,
        category: 'Organic scraps',
        kg: kg,
        window: 0,
        donate: true,
        price: 0,
        storage: 'Separated bin',
        allergens: 'Not for consumption',
        waste: true,
      );
      bin.fill = 0;
    }
    notices.insert(
      0,
      'Full bins emptied to the waste assessment queue. Facility suitability must be checked before dispatch.',
    );
    _commit();
  }

  String report() => const JsonEncoder.withIndent('  ').convert({
    'report': 'ResQ-Haul DEMO — not a tax receipt',
    'edibleKg': donated + sold,
    'resourceRecoveryKg': recovered,
    'salesRM': revenue,
    'records': batches.map((b) => b.toJson()).toList(),
  });
}
