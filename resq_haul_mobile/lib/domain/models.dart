enum Stage {
  listed,
  accepted,
  assigned,
  transit,
  delivered,
  waste,
  assessed,
  collected,
  facilityAccepted,
  processing,
  completed,
  rejected,
}

extension StageLabel on Stage {
  String get label => const [
    'Available',
    'Recipient confirmed',
    'Driver assigned',
    'In transit',
    'Delivered',
    'Waste assessment',
    'Collection ready',
    'At facility',
    'Load accepted',
    'Processing',
    'Recovery complete',
    'Load rejected',
  ][index];
  bool get edible => index < Stage.delivered.index;
  bool get downstream => index >= Stage.waste.index;
}

enum AppRole { kitchen, recipient, driver, recovery }

extension RoleLabel on AppRole {
  String get label =>
      const ['Kitchen', 'Recipient', 'Driver', 'Recovery team'][index];
  String get person => const ['Aminah', 'Sofia', 'Raju', 'Farah'][index];
}

class Batch {
  Batch({
    required this.id,
    required this.name,
    required this.category,
    required this.kg,
    required this.deadline,
    this.source = 'Tunas Kitchen',
    this.donate = true,
    this.price = 0,
    this.stage = Stage.listed,
    this.recipient = '',
    this.driver = '',
    this.distance = 3,
    this.delay = 0,
    this.traffic = 1.3,
    this.temperature = 32,
    this.storage = 'Chilled',
    this.allergens = 'None declared',
    this.facility = '',
    this.material = 'Separated organics',
    this.measuredKg = 0,
    this.rerouted = false,
    this.switched = false,
    this.pickedUp = false,
    this.receipt = '',
    this.rejection = '',
    this.createdAt = 0,
    List<String>? history,
  }) : history = history ?? ['Surplus listed by kitchen'];
  final String id;
  String name,
      category,
      source,
      recipient,
      driver,
      storage,
      allergens,
      facility,
      material,
      receipt,
      rejection;
  double kg, price, distance, traffic, measuredKg;
  int deadline, delay, temperature, createdAt;
  bool donate, rerouted, switched, pickedUp;
  Stage stage;
  List<String> history;
  int remaining(int clock) => (deadline - clock).clamp(0, 100000);
  int eta({double? km, bool fresh = false}) =>
      ((pickedUp ? 0 : 10) +
              (km ?? distance) * 3 * traffic +
              (temperature - 25).clamp(0, 20) * .7 +
              (fresh ? 0 : delay) +
              8)
          .ceil();
  bool eligible(int clock, {double? km, bool fresh = false}) =>
      stage.edible && remaining(clock) > eta(km: km, fresh: fresh);
  double radius(int clock) =>
      ((remaining(clock) -
                  (pickedUp ? 0 : 10) -
                  8 -
                  (temperature - 25).clamp(0, 20) * .7 -
                  delay) /
              (3 * traffic))
          .clamp(0, 50);
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'kg': kg,
    'deadline': deadline,
    'source': source,
    'donate': donate,
    'price': price,
    'stage': stage.name,
    'recipient': recipient,
    'driver': driver,
    'distance': distance,
    'delay': delay,
    'traffic': traffic,
    'temperature': temperature,
    'storage': storage,
    'allergens': allergens,
    'facility': facility,
    'material': material,
    'measuredKg': measuredKg,
    'rerouted': rerouted,
    'switched': switched,
    'pickedUp': pickedUp,
    'receipt': receipt,
    'rejection': rejection,
    'createdAt': createdAt,
    'history': history,
  };
  factory Batch.fromJson(Map<String, dynamic> j) => Batch(
    id: j['id'],
    name: j['name'],
    category: j['category'],
    kg: (j['kg'] as num).toDouble(),
    deadline: j['deadline'],
    source: j['source'],
    donate: j['donate'],
    price: (j['price'] as num).toDouble(),
    stage: Stage.values.byName(j['stage']),
    recipient: j['recipient'],
    driver: j['driver'],
    distance: (j['distance'] as num).toDouble(),
    delay: j['delay'],
    traffic: (j['traffic'] as num).toDouble(),
    temperature: j['temperature'],
    storage: j['storage'],
    allergens: j['allergens'],
    facility: j['facility'],
    material: j['material'],
    measuredKg: (j['measuredKg'] as num).toDouble(),
    rerouted: j['rerouted'],
    switched: j['switched'],
    pickedUp: j['pickedUp'],
    receipt: j['receipt'],
    rejection: j['rejection'],
    createdAt: j['createdAt'],
    history: List<String>.from(j['history']),
  );
}

class Receiver {
  const Receiver(this.name, this.km, this.capacity, this.categories);
  final String name;
  final double km, capacity;
  final List<String> categories;
}

const receivers = [
  Receiver('Community Kitchen', 3, 35, ['Meals', 'Rice', 'Bread', 'Produce']),
  Receiver('Neighbourhood Pantry', 1.5, 25, [
    'Meals',
    'Rice',
    'Bread',
    'Produce',
  ]),
  Receiver('Chow Kit Food Bank', 4, 8, ['Rice', 'Bread', 'Produce']),
];

class Facility {
  const Facility(
    this.name,
    this.type,
    this.capacity,
    this.materials,
    this.description,
  );
  final String name, type, description;
  final double capacity;
  final List<String> materials;
}

const facilities = [
  Facility(
    'Klang Valley BSFL Centre',
    'BSFL',
    300,
    ['Separated organics', 'Plant scraps'],
    'Inspect → weigh → contained receiving → larvae growth → separation → feed processing & residue treatment',
  ),
  Facility(
    'Kebun Community Compost',
    'Compost',
    180,
    ['Plant scraps'],
    'Inspect → weigh → aerobic composting → curing → compost',
  ),
  Facility(
    'Circular Energy Hub',
    'Biogas',
    500,
    ['Separated organics', 'Plant scraps'],
    'Inspect → weigh → anaerobic digestion → biogas & digestate treatment',
  ),
];

class SmartBin {
  SmartBin(
    this.id,
    this.name,
    this.fill, {
    this.capacity = 100,
    this.online = true,
  });
  String id, name;
  double fill, capacity;
  bool online;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fill': fill,
    'capacity': capacity,
    'online': online,
  };
  factory SmartBin.fromJson(Map<String, dynamic> j) => SmartBin(
    j['id'],
    j['name'],
    (j['fill'] as num).toDouble(),
    capacity: (j['capacity'] as num).toDouble(),
    online: j['online'],
  );
}
